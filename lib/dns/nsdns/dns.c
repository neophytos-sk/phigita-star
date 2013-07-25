/*
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1(the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/.
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis,WITHOUT WARRANTY OF ANY KIND,either express or implied. See
 * the License for the specific language governing rights and limitations
 * under the License.
 *
 * Alternatively,the contents of this file may be used under the terms
 * of the GNU General Public License(the "GPL"),in which case the
 * provisions of GPL are applicable instead of those above.  If you wish
 * to allow use of your version of this file only under the terms of the
 * GPL and not to allow others to use your version of this file under the
 * License,indicate your decision by deleting the provisions above and
 * replace them with the notice and other provisions required by the GPL.
 * If you do not delete the provisions above,a recipient may use your
 * version of this file under either the License or the GPL.
 *
 * Author Vlad Seryakov vlad@crystalballinc.com
 *
 */

#define USE_TCL8X
#include "ns.h"
#include "dns.h"

#define DNS_BUFSIZE 536

typedef struct _dnsServer {
    struct _dnsServer *next;
    char *name;
    unsigned long ipaddr;
    unsigned long fail_time;
    unsigned long fail_count;
} dnsServer;

int dnsDebug = 0;
int dnsTTL = 86400;
int dnsFlags = 0;

static Ns_Mutex dnsMutex;
static dnsServer *dnsServers = 0;
static int dnsResolverRetries = 3;
static int dnsResolverTimeout = 5;
static int dnsFailureTimeout = 300;

static struct {
   char *name;
   int type;
} dnsTypes[] = {
   { "ANY",   DNS_TYPE_ANY },
   { "A",     DNS_TYPE_A },
   { "NS",    DNS_TYPE_NS },
   { "CNAME", DNS_TYPE_CNAME },
   { "SOA",   DNS_TYPE_SOA },
   { "PTR",   DNS_TYPE_PTR },
   { "NAPTR", DNS_TYPE_NAPTR },
   { "MX",    DNS_TYPE_MX },
   { NULL,    0 }
};

void dnsInit(char *name, ...)
{
    va_list ap;

    Ns_MutexLock(&dnsMutex);
    va_start(ap, name);

    if (!strcmp(name, "nameserver")) {
        char *s, *n;
        dnsServer *server, *next;
        while ((s = va_arg(ap, char *))) {
            while (s) {
                if ((n = strchr(s, ','))) {
                    *n++ = 0;
                }
                server = ns_calloc(1, sizeof(dnsServer));
                server->name = ns_strdup(s);
                server->ipaddr = inet_addr(s);
                for (next = dnsServers; next && next->next; next = next->next);
                if (!next) {
                    dnsServers = server;
                } else {
                    next->next = server;
                }
                s = n;
            }
        }
    } else
     if (!strcmp(name, "debug")) {
        dnsDebug = va_arg(ap, int);
    } else
     if (!strcmp(name, "retry")) {
        dnsResolverRetries = va_arg(ap, int);
    } else
     if (!strcmp(name, "timeout")) {
        dnsResolverTimeout = va_arg(ap, int);
    } else
     if (!strcmp(name, "failuretimeout")) {
        dnsFailureTimeout = va_arg(ap, int);
    } else
     if (!strcmp(name, "ttl")) {
        dnsTTL = va_arg(ap, int);
    }
    va_end(ap);
    Ns_MutexUnlock(&dnsMutex);
}

dnsPacket *dnsLookup(char *name, int type, int *errcode)
{
    fd_set fds;
    char buf[DNS_BUFSIZE];
    struct timeval tv;
    dnsServer *server = 0;
    dnsPacket *req, *reply;
    struct sockaddr_in saddr;
    int sock, len, timeout, retries, now;

    if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
        if (errcode) {
            *errcode = errno;
        }
        return 0;
    }
    req = dnsPacketCreateQuery(name, type);
    dnsEncodePacket(req);
    saddr.sin_family = AF_INET;
    saddr.sin_port = htons(53);

    while (1) {
        now = time(0);
        Ns_MutexLock(&dnsMutex);
        retries = dnsResolverRetries;
        timeout = dnsResolverTimeout;
        if (server) {
            /* Disable only if we have more than one server */
            if (++server->fail_count > 2 && dnsServers->next) {
                server->fail_time = now;
                Ns_Log(Notice, "dnsLookup: %s: nameserver disabled", server->name);
            }
            server = server->next;
        } else {
            server = dnsServers;
        }
        while (server) {
            if (server->fail_time && now - server->fail_time > dnsFailureTimeout) {
                server->fail_count = server->fail_time = 0;
                Ns_Log(Notice, "dnsLookup: %s: nameserver re-enabled", server->name);
            }
            if (!server->fail_time) {
                break;
            }
            server = server->next;
        }
        Ns_MutexUnlock(&dnsMutex);
        if (!server) {
            break;
        }
        if (dnsDebug > 5) {
            Ns_Log(Notice, "dnsLookup: %s: resolving %s...", server->name, name);
        }
        saddr.sin_addr.s_addr = server->ipaddr;
        while (retries--) {
            len = sizeof(struct sockaddr_in);
            if (sendto(sock, req->buf.data + 2, req->buf.size, 0, (struct sockaddr *) &saddr, len) < 0) {
                if (dnsDebug > 3) {
                    Ns_Log(Error, "dnsLookup: %s: sendto: %s", server->name, strerror(errno));
                }
                continue;
            }
            tv.tv_usec = 0;
            tv.tv_sec = timeout;
            FD_ZERO(&fds);
            FD_SET(sock, &fds);
            if (select(sock + 1, &fds, 0, 0, &tv) <= 0 || !FD_ISSET(sock, &fds)) {
                if (dnsDebug > 3 && errno) {
                    Ns_Log(Error, "dnsLookup: %s: select: %s", server->name, strerror(errno));
                }
                continue;
            }
            if ((len = recv(sock, buf, DNS_BUFSIZE, 0)) <= 0) {
                if (dnsDebug > 3) {
                    Ns_Log(Error, "dnsLookup: %s: recvfrom: %s", server->name, strerror(errno));
                }
                continue;
            }
            if (!(reply = dnsParsePacket((unsigned char*)buf, len))) {
                continue;
            }
            // DNS packet id should be the same
            if (reply->id == req->id) {
                close(sock);
                dnsPacketFree(req, 0);
                Ns_MutexLock(&dnsMutex);
                server->fail_count = server->fail_time = 0;
                Ns_MutexUnlock(&dnsMutex);
                return reply;
            }
            dnsPacketFree(reply, 0);
        }
    }
    dnsPacketFree(req, 0);
    close(sock);
    if (errcode) {
        *errcode = ENOENT;
    }
    return 0;
}

dnsPacket *dnsResolve(char *name, int type, char *server, int timeout, int retries)
{
    fd_set fds;
    int sock, len;
    char buf[DNS_BUFSIZE];
    dnsPacket *req, *reply;
    struct timeval tv;
    struct sockaddr_in saddr;

    if (retries <= 0) {
        retries = 3;
    }
    if (timeout <= 0) {
        timeout = 5;
    }
    if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
        if (dnsDebug > 3) {
            Ns_Log(Error, "dnsResolve: %s: socket: %s", name, strerror(errno));
        }
        return 0;
    }
    saddr.sin_addr.s_addr = inet_addr(server);
    saddr.sin_family = AF_INET;
    saddr.sin_port = htons(53);
    req = dnsPacketCreateQuery(name, type);
    dnsEncodePacket(req);
    while (retries--) {
        len = sizeof(struct sockaddr_in);
        if (sendto(sock, req->buf.data + 2, req->buf.size, 0, (struct sockaddr *) &saddr, len) < 0) {
            if (dnsDebug > 3) {
                Ns_Log(Error, "dnsResolve: %s: sendto: %s", name, strerror(errno));
            }
            continue;
        }
        if (dnsDebug > 3) {
            Ns_Log(Notice, "dnsResolve: %s: %d: sending to %s, timeout=%d", name, req->id, server, timeout);
        }
        tv.tv_usec = 0;
        tv.tv_sec = timeout;
        FD_ZERO(&fds);
        FD_SET(sock, &fds);
        if (select(sock + 1, &fds, 0, 0, &tv) <= 0 || !FD_ISSET(sock, &fds)) {
            if (dnsDebug > 3 && errno) {
                Ns_Log(Error, "dnsResolve: %s: select: %s", name, strerror(errno));
            }
            continue;
        }
        if ((len = recv(sock, buf, DNS_BUFSIZE, 0)) <= 0) {
            if (dnsDebug > 3) {
                Ns_Log(Error, "dnsResolve: %s: recvfrom: %s", name, strerror(errno));
            }
            continue;
        }
        if (dnsDebug > 3) {
            Ns_Log(Notice, "dnsResolve: %s: received %d bytes from %s", name, len, server);
        }
        if (!(reply = dnsParsePacket((unsigned char*)buf, len))) {
            continue;
        }
        // DNS packet id should be the same
        if (reply->id == req->id) {
            dnsPacketFree(req, 0);
            close(sock);
            return reply;
        }
        if (dnsDebug > 3) {
            Ns_Log(Notice, "dnsResolve: %s: %d: wrong ID %d from to %s", name, req->id, reply->id, server);
        }
        dnsPacketFree(reply, 0);
    }
    dnsPacketFree(req, 0);
    close(sock);
    return 0;
}

void dnsRecordDump(Ns_DString * ds, dnsRecord * y)
{
    if (!y) {
        return;
    }
    Ns_DStringPrintf(ds, "Name=%s, Type=%s(%d), Class=%u, TTL=%lu, Length=%u, ",
                     y->name, dnsTypeStr(y->type), y->type, y->class, y->ttl, y->len);
    switch (y->type) {
    case DNS_TYPE_A:
        Ns_DStringPrintf(ds, "IP=%s ", ns_inet_ntoa(y->data.ipaddr));
        break;
    case DNS_TYPE_MX:
        if (!y->data.mx) {
            break;
        }
        Ns_DStringPrintf(ds, "MX=%u, %s ", y->data.mx->preference, y->data.mx->name);
        break;
    case DNS_TYPE_NS:
        Ns_DStringPrintf(ds, "NS=%s ", y->data.name);
        break;
    case DNS_TYPE_CNAME:
        Ns_DStringPrintf(ds, "CNAME=%s ", y->data.name);
        break;
    case DNS_TYPE_PTR:
        Ns_DStringPrintf(ds, "PTR=%s ", y->data.name);
        break;
    case DNS_TYPE_SOA:
        if (!y->data.soa) {
            break;
        }
        Ns_DStringPrintf(ds, "MNAME=%s, RNAME=%s, SERIAL=%lu, REFRESH=%lu, RETRY=%lu, EXPIRE=%lu, TTL=%lu ",
                         y->data.soa->mname, y->data.soa->rname, y->data.soa->serial,
                         y->data.soa->refresh, y->data.soa->retry, y->data.soa->expire, y->data.soa->ttl);
        break;
    case DNS_TYPE_NAPTR:
        if (!y->data.naptr) {
            break;
        }
        Ns_DStringPrintf(ds, "ORDER=%d, PREFS=%d, FLAGS=%s, SERVICE=%s, REGEXP=%s, REPLACE=%s, TTL=%lu ",
                         y->data.naptr->order, y->data.naptr->preference, y->data.naptr->flags, y->data.naptr->service,
                         y->data.naptr->regexp, y->data.naptr->replace, y->data.soa->ttl);
        break;
    }
    if (y->timestamp) {
        Ns_DStringPrintf(ds, ", TIMESTAMP=%lu", y->timestamp);
    }
}

void dnsRecordLog(dnsRecord * rec, int level, char *text, ...)
{
    Ns_DString ds;
    va_list ap;

    if (level > dnsDebug) {
        return;
    }
    va_start(ap, text);

    Ns_DStringInit(&ds);
    Ns_DStringAppend(&ds, "nsdns: ");
    Ns_DStringVPrintf(&ds, text, ap);
    dnsRecordDump(&ds, rec);
    Ns_Log(level < 0 ? Error : Notice, ds.string);
    Ns_DStringFree(&ds);
    va_end(ap);
}

void dnsRecordFree(dnsRecord * pkt)
{
    if (!pkt) {
        return;
    }
    ns_free(pkt->name);
    switch (pkt->type) {
    case DNS_TYPE_MX:
        if (!pkt->data.mx) {
            break;
        }
        ns_free(pkt->data.mx->name);
        ns_free(pkt->data.mx);
        break;
    case DNS_TYPE_NS:
    case DNS_TYPE_CNAME:
    case DNS_TYPE_PTR:
        ns_free(pkt->data.name);
        break;
    case DNS_TYPE_NAPTR:
        if (!pkt->data.naptr) {
            break;
        }
        ns_free(pkt->data.naptr->flags);
        ns_free(pkt->data.naptr->service);
        ns_free(pkt->data.naptr->regexp);
        ns_free(pkt->data.naptr->replace);
        break;
    case DNS_TYPE_SOA:
        if (!pkt->data.soa) {
            break;
        }
        ns_free(pkt->data.soa->mname);
        ns_free(pkt->data.soa->rname);
        ns_free(pkt->data.soa);
        break;
    }
    ns_free(pkt);
}

void dnsRecordDestroy(dnsRecord ** pkt)
{
    if (!pkt) {
        return;
    }
    while (*pkt) {
        dnsRecord *next = (*pkt)->next;
        dnsRecordFree(*pkt);
        *pkt = next;
    }
}

dnsRecord *dnsRecordCreate(dnsRecord * from)
{
    dnsRecord *rec = ns_calloc(1, sizeof(dnsRecord));
    if (from) {
        rec->name = ns_strcopy(from->name);
        rec->nsize = from->nsize;
        rec->type = from->type;
        rec->class = from->class;
        rec->ttl = from->ttl;
        rec->len = from->len;
        switch (rec->type) {
        case DNS_TYPE_A:
            rec->data.ipaddr.s_addr = from->data.ipaddr.s_addr;
            break;
        case DNS_TYPE_MX:
            rec->data.mx = ns_calloc(1, sizeof(dnsMX));
            if (!from->data.mx) {
                break;
            }
            rec->data.mx->name = ns_strcopy(from->data.mx->name);
            rec->data.mx->preference = from->data.mx->preference;
            break;
        case DNS_TYPE_NS:
        case DNS_TYPE_CNAME:
        case DNS_TYPE_PTR:
            rec->data.name = ns_strcopy(from->data.name);
            break;
        case DNS_TYPE_NAPTR:
            rec->data.naptr = ns_calloc(1, sizeof(dnsNAPTR));
            if (!from->data.naptr) {
                break;
            }
            rec->data.naptr->order = from->data.naptr->order;
            rec->data.naptr->preference = from->data.naptr->preference;
            rec->data.naptr->flags = ns_strcopy(from->data.naptr->flags);
            rec->data.naptr->service = ns_strcopy(from->data.naptr->service);
            rec->data.naptr->regexp = ns_strcopy(from->data.naptr->regexp);
            rec->data.naptr->replace = ns_strcopy(from->data.naptr->replace);
            break;
        case DNS_TYPE_SOA:
            rec->data.soa = ns_calloc(1, sizeof(dnsSOA));
            if (!from->data.soa) {
                break;
            }
            rec->data.soa->mname = ns_strcopy(from->data.soa->mname);
            rec->data.soa->rname = ns_strcopy(from->data.soa->rname);
            rec->data.soa->serial = from->data.soa->serial;
            rec->data.soa->refresh = from->data.soa->refresh;
            rec->data.soa->retry = from->data.soa->retry;
            rec->data.soa->expire = from->data.soa->expire;
            rec->data.soa->ttl = from->data.soa->ttl;
            break;
        }
        dnsRecordUpdate(rec);
    }
    return rec;
}

dnsRecord *dnsRecordCreateA(char *name, unsigned long ipaddr)
{
    dnsRecord *y = ns_calloc(1, sizeof(dnsRecord));

    y->nsize = strlen(name);
    y->name = ns_malloc(y->nsize + 1);
    strcpy(y->name, name);
    y->type = DNS_TYPE_A;
    y->class = DNS_CLASS_INET;
    y->len = 4;
    y->data.ipaddr.s_addr = ipaddr;
    y->ttl = dnsTTL;
    return y;
}

dnsRecord *dnsRecordCreateNS(char *name, char *data)
{
    dnsRecord *y = ns_calloc(1, sizeof(dnsRecord));
    y->nsize = strlen(name);
    y->name = ns_malloc(y->nsize + 1);
    strcpy(y->name, name);
    y->type = DNS_TYPE_NS;
    y->class = DNS_CLASS_INET;
    y->data.name = ns_strcopy(data);
    if (y->data.name) {
        y->len = strlen(y->data.name);
    }
    y->ttl = dnsTTL;
    return y;
}

dnsRecord *dnsRecordCreateCNAME(char *name, char *data)
{
    dnsRecord *y = ns_calloc(1, sizeof(dnsRecord));
    y->nsize = strlen(name);
    y->name = ns_malloc(y->nsize + 1);
    strcpy(y->name, name);
    y->type = DNS_TYPE_CNAME;
    y->class = DNS_CLASS_INET;
    y->data.name = ns_strcopy(data);
    if (y->data.name) {
        y->len = strlen(y->data.name);
    }
    y->ttl = dnsTTL;
    return y;
}

dnsRecord *dnsRecordCreatePTR(char *name, char *data)
{
    dnsRecord *y = ns_calloc(1, sizeof(dnsRecord));
    y->nsize = strlen(name);
    y->name = ns_malloc(y->nsize + 1);
    strcpy(y->name, name);
    y->type = DNS_TYPE_PTR;
    y->class = DNS_CLASS_INET;
    y->data.name = ns_strcopy(data);
    if (y->data.name) {
        y->len = strlen(y->data.name);
    }
    y->ttl = dnsTTL;
    return y;
}

dnsRecord *dnsRecordCreateMX(char *name, int preference, char *data)
{
    dnsRecord *y = ns_calloc(1, sizeof(dnsRecord));
    y->nsize = strlen(name);
    y->name = ns_malloc(y->nsize + 1);
    strcpy(y->name, name);
    y->type = DNS_TYPE_MX;
    y->class = DNS_CLASS_INET;
    y->data.mx = ns_calloc(1, sizeof(dnsMX));
    y->data.mx->preference = preference;
    y->data.mx->name = ns_strcopy(data);
    y->len = 2;
    if (y->data.name) {
        y->len += strlen(y->data.name);
    }
    y->ttl = dnsTTL;
    return y;
}

dnsRecord *dnsRecordCreateNAPTR(char *name, int order, int preference, char *flags, char *service, char *regexp,
                                char *replace)
{
    dnsRecord *y = ns_calloc(1, sizeof(dnsRecord));
    y->nsize = strlen(name);
    y->name = ns_malloc(y->nsize + 1);
    strcpy(y->name, name);
    y->type = DNS_TYPE_NAPTR;
    y->class = DNS_CLASS_INET;
    y->data.naptr = ns_calloc(1, sizeof(dnsNAPTR));
    y->data.naptr->order = order;
    y->data.naptr->preference = preference;
    y->data.naptr->flags = ns_strcopy(flags);
    y->data.naptr->service = ns_strcopy(service);
    y->data.naptr->regexp = ns_strcopy(regexp && *regexp ? regexp : 0);
    y->data.naptr->replace = ns_strcopy(replace && *replace ? replace : 0);
    y->len = 2;
    if (y->data.name) {
        y->len += strlen(y->data.name);
    }
    y->ttl = dnsTTL;
    return y;
}

dnsRecord *dnsRecordCreateSOA(char *name, char *mname, char *rname,
                              unsigned long serial, unsigned long refresh,
                              unsigned long retry, unsigned long expire, unsigned long ttl)
{
    dnsRecord *y = ns_calloc(1, sizeof(dnsRecord));
    y->nsize = strlen(name);
    y->name = ns_malloc(y->nsize + 1);
    strcpy(y->name, name);
    y->type = DNS_TYPE_SOA;
    y->class = DNS_CLASS_INET;
    y->data.soa = ns_calloc(1, sizeof(dnsSOA));
    y->data.soa->mname = ns_strcopy(mname);
    y->data.soa->rname = ns_strcopy(rname);
    y->data.soa->serial = serial;
    y->data.soa->refresh = refresh;
    y->data.soa->retry = retry;
    y->data.soa->expire = expire;
    y->data.soa->ttl = ttl ? ttl : dnsTTL;
    y->len = 20;
    if (y->data.soa->mname) {
        y->len += strlen(y->data.soa->mname);

    }
    if (y->data.soa->rname) {
        y->len += strlen(y->data.soa->rname);
    }
    y->ttl = dnsTTL;
    return y;
}

Tcl_Obj *dnsRecordCreateTclObj(Tcl_Interp * interp, dnsRecord * drec)
{
    Tcl_Obj *list = Tcl_NewListObj(0, 0);

    while (drec) {
        Tcl_Obj *obj = Tcl_NewListObj(0, 0);
        Tcl_ListObjAppendElement(interp, obj, Tcl_NewStringObj(drec->name, -1));
        Tcl_ListObjAppendElement(interp, obj, Tcl_NewStringObj((char *) dnsTypeStr(drec->type), -1));
        switch (drec->type) {
        case DNS_TYPE_A:
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewStringObj(ns_inet_ntoa(drec->data.ipaddr), -1));
            break;
        case DNS_TYPE_MX:
            if (!drec->data.mx) {
                break;
            }
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewStringObj(drec->data.mx->name, -1));
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewIntObj(drec->data.mx->preference));
            break;
        case DNS_TYPE_NAPTR:
            if (!drec->data.naptr) {
                break;
            }
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewIntObj(drec->data.naptr->order));
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewIntObj(drec->data.naptr->preference));
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewStringObj(drec->data.naptr->flags, -1));
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewStringObj(drec->data.naptr->service, -1));
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewStringObj(drec->data.naptr->regexp, -1));
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewStringObj(drec->data.naptr->replace, -1));
            break;
        case DNS_TYPE_SOA:
            if (!drec->data.soa) {
                break;
            }
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewStringObj(drec->data.soa->mname, -1));
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewStringObj(drec->data.soa->rname, -1));
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewIntObj(drec->data.soa->serial));
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewIntObj(drec->data.soa->refresh));
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewIntObj(drec->data.soa->retry));
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewIntObj(drec->data.soa->expire));
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewIntObj(drec->data.soa->ttl));
            break;
        default:
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewStringObj(drec->data.name, -1));
        }
        Tcl_ListObjAppendElement(interp, obj, Tcl_NewIntObj(drec->ttl));
        Tcl_ListObjAppendElement(interp, list, obj);
        drec = drec->next;
    }
    return list;
}

void dnsRecordUpdate(dnsRecord * rec)
{
    switch (rec->type) {
    case DNS_TYPE_NAPTR:
        // Save pointer in the regexp where phone number should be
        // placed for quick replace later
        if (!(dnsFlags & DNS_NAPTR_REGEXP && rec->data.naptr->regexp)) {
            break;
        }
        if ((rec->data.naptr->regexp_p2 = strchr(rec->data.naptr->regexp, '@'))) {
            for (rec->data.naptr->regexp_p1 = rec->data.naptr->regexp_p2;
                 rec->data.naptr->regexp_p1 > rec->data.naptr->regexp &&
                 *rec->data.naptr->regexp_p1 != ':'; rec->data.naptr->regexp_p1--);
        }
        break;
    }
}

dnsRecord *dnsRecordAppend(dnsRecord ** list, dnsRecord * pkt)
{
    if (!list || !pkt) {
        return 0;
    }
    for (; *list; list = &(*list)->next);
    *list = pkt;
    return *list;
}

dnsRecord *dnsRecordInsert(dnsRecord ** list, dnsRecord * pkt)
{
    if (!list || !pkt) {
        return 0;
    }
    pkt->next = *list;
    *list = pkt;
    return *list;
}

dnsRecord *dnsRecordRemove(dnsRecord ** list, dnsRecord * link)
{
    if (!list || !link) {
        return 0;
    }
    for (; *list; list = &(*list)->next) {
        if (*list != link) {
            continue;
        }
        if (link->next) {
            link->next->prev = link->prev;
        }
        if (link->prev) {
            link->prev->next = link->next;
        }
        *list = link->next;
        link->next = link->prev = 0;
        return link;
    }
    return 0;
}

int dnsRecordSearch(dnsRecord * list, dnsRecord * rec, int replace)
{
    dnsRecord *drec;

    for (drec = list; drec; drec = drec->next) {
        if (drec->type != rec->type) {
            continue;
        }
        switch (drec->type) {
        case DNS_TYPE_A:
            if (rec->data.ipaddr.s_addr == drec->data.ipaddr.s_addr) {
                if (replace) {
                    rec->ttl = drec->ttl;
                }
                return 1;
            }
            break;
        case DNS_TYPE_NS:
        case DNS_TYPE_CNAME:
        case DNS_TYPE_PTR:
            if (!rec->data.name || !drec->data.name) {
                return -1;
            }
            if (!strcmp(rec->data.name, drec->data.name)) {
                if (replace) {
                    rec->ttl = drec->ttl;
                }
                return 1;
            }
            break;
        case DNS_TYPE_MX:
            if (!rec->data.mx || !rec->data.mx->name || !drec->data.mx || !drec->data.mx->name) {
                return -1;
            }
            if (!strcmp(rec->data.mx->name, drec->data.mx->name)) {
                if (replace) {
                    rec->ttl = drec->ttl;
                    rec->data.mx->preference = drec->data.mx->preference;
                }
                return 1;
            }
            break;
        case DNS_TYPE_NAPTR:
            if (!rec->data.naptr || !drec->data.naptr ||
                (!rec->data.naptr->regexp && !rec->data.naptr->replace) ||
                (!drec->data.naptr->regexp && !drec->data.naptr->replace)) {
                return -1;
            }
            if ((rec->data.naptr->regexp && drec->data.naptr->regexp &&
                 !strcmp(rec->data.naptr->regexp, drec->data.naptr->regexp)) ||
                (rec->data.naptr->replace && drec->data.naptr->replace &&
                 !strcmp(rec->data.naptr->replace, drec->data.naptr->replace))) {
                if (replace) {
                    rec->ttl = drec->ttl;
                    rec->data.mx->preference = drec->data.mx->preference;
                }
                return 1;
            }
            break;
        case DNS_TYPE_SOA:
            if (!rec->data.soa || !drec->data.soa) {
                return -1;
            }
            /* Only one SOA record per domain */
            if (replace) {
                rec->ttl = drec->ttl;
                if (rec->data.soa->serial != drec->data.soa->serial) {
                    ns_free(rec->data.soa->mname);
                    rec->data.soa->mname = ns_strcopy(drec->data.soa->mname);
                    ns_free(rec->data.soa->rname);
                    rec->data.soa->rname = ns_strcopy(drec->data.soa->rname);
                    rec->data.soa->serial = drec->data.soa->serial;
                    rec->data.soa->refresh = drec->data.soa->refresh;
                    rec->data.soa->retry = drec->data.soa->retry;
                    rec->data.soa->expire = drec->data.soa->expire;
                    rec->data.soa->ttl = drec->data.soa->ttl;
                }
            }
            return 1;
        default:
            return -1;
        }
    }
    return 0;
}

int dnsParseString(dnsPacket * pkt, char **buf)
{
    int len;

    if (!(len = *pkt->buf.ptr++)) {
        return 0;
    }
    if (pkt->buf.ptr + len > pkt->buf.data + pkt->buf.allocated) {
        return -1;
    }
    *buf = ns_malloc(len + 1);
    strncpy(*buf, pkt->buf.ptr, len);
    (*buf)[len] = 0;
    pkt->buf.ptr += len;
    return 0;
}

int dnsParseName(dnsPacket * pkt, char **ptr, char *buf, int buflen, int pos, int level)
{
    unsigned short i, len, offset;
    char *p;

    if (level > 15) {
        Ns_Log(Error, "nsdns: infinite loop %d: %d", (*ptr - pkt->buf.data) - 2, level);
        return -9;
    }
    while ((len = *((*ptr)++)) != 0) {
        switch (len & 0xC0) {
        case 0xC0:
            if ((offset = ((len & ~0xC0) << 8) + (u_char) ** ptr) >= pkt->buf.size) {
                return -1;
            }
            (*ptr)++;
            p = &pkt->buf.data[offset + 2];
            return dnsParseName(pkt, &p, buf, buflen, pos, level + 1);
        case 0x80:
        case 0x40:
            return -2;
        }
        if (len > buflen) {
            return -3;
        }
        for (i = 0; i < len; i++) {
            if (--buflen <= 0) {
                return -4;
            }
            buf[pos++] = **ptr;
            (*ptr)++;
        }
        if (--buflen <= 0) {
            return -5;
        }
        buf[pos++] = '.';
    }
    buf[pos] = 0;
    // Remove last . in the name
    if (buf[pos - 1] == '.') {
        buf[--pos] = 0;
    }
    return pos;
}

dnsPacket *dnsParseHeader(void *buf, int size)
{
    unsigned short *p;
    dnsPacket *pkt;

    pkt = ns_calloc(1, sizeof(dnsPacket));
    p = (unsigned short *) buf;
    pkt->id = ntohs(p[0]);
    pkt->u = ntohs(p[1]);
    pkt->qdcount = ntohs(p[2]);
    pkt->ancount = ntohs(p[3]);
    pkt->nscount = ntohs(p[4]);
    pkt->arcount = ntohs(p[5]);
    /* First two bytes are reserved for packet length
       in TCP mode plus some overhead in case we compress worse
       than it was */
    pkt->buf.allocated = size + 128;
    pkt->buf.data = ns_malloc(pkt->buf.allocated);
    //Ns_Log(Debug,"parse[%d]: %x %x, %d",getpid(),pkt,pkt->buf.data,pkt->buf.allocated);
    pkt->buf.size = size;
    memcpy(pkt->buf.data + 2, buf, (unsigned) size);
    pkt->buf.ptr = &pkt->buf.data[DNS_HEADER_LEN + 2];
    return pkt;
}

dnsRecord *dnsParseRecord(dnsPacket * pkt, int query)
{
    int offset;
    unsigned long ul;
    unsigned short us;
    char name[256] = "";
    dnsRecord *y;

    y = ns_calloc(1, sizeof(dnsRecord));
    offset = (pkt->buf.ptr - pkt->buf.data) - 2;
    // The name of the resource
    if ((y->nsize = dnsParseName(pkt, &pkt->buf.ptr, name, 255, 0, 0)) < 0) {
        snprintf(name, 255, "invalid name: %d %s: ", y->nsize, pkt->buf.ptr);
        goto err;
    }
    y->name = ns_malloc(y->nsize + 1);
    strcpy(y->name, name);
    // The type of data
    if (pkt->buf.ptr + 2 > pkt->buf.data + pkt->buf.allocated) {
        strcpy(name, "invalid type position");
        goto err;
    }
    memcpy(&us, pkt->buf.ptr, sizeof(us));
    y->type = ntohs(us);
    pkt->buf.ptr += 2;
    // The class type
    if (pkt->buf.ptr + 2 > pkt->buf.data + pkt->buf.allocated) {
        strcpy(name, "invalid class position");
        goto err;
    }
    memcpy(&us, pkt->buf.ptr, sizeof(us));
    y->class = ntohs(us);
    pkt->buf.ptr += 2;
    // Query block stops here
    if (query)
        goto rec;
    // Answer blocks carry a TTL and the actual data.
    if (pkt->buf.ptr + 4 > pkt->buf.data + pkt->buf.allocated) {
        strcpy(name, "invalid TTL position");
        goto err;
    }
    memcpy(&ul, pkt->buf.ptr, sizeof(ul));
    y->ttl = ntohl(ul);
    pkt->buf.ptr += 4;
    // Fetch the resource data.
    if (pkt->buf.ptr + 2 > pkt->buf.data + pkt->buf.allocated) {
        strcpy(name, "invalid data position");
        goto err;
    }
    memcpy(&us, pkt->buf.ptr, sizeof(us));
    if (!(y->len = ntohs(us))) {
        strcpy(name, "empty data len");
        goto err;
    }
    pkt->buf.ptr += 2;
    if (pkt->buf.ptr + y->len > pkt->buf.data + pkt->buf.allocated) {
        strcpy(name, "invalid data len");
        goto err;
    }
    switch (y->type) {
    case DNS_TYPE_A:
        memcpy(&y->data.ipaddr, pkt->buf.ptr, 4);
        pkt->buf.ptr += 4;
        break;
    case DNS_TYPE_MX:
        y->data.soa = ns_calloc(1, sizeof(dnsSOA));
        memcpy(&us, pkt->buf.ptr, sizeof(us));
        y->data.mx->preference = ntohs(us);
        pkt->buf.ptr += 2;
        if (dnsParseName(pkt, &pkt->buf.ptr, name, 255, 0, 0) < 0) {
            goto err;
        }
        y->data.mx->name = ns_strcopy(name);
        break;
    case DNS_TYPE_NS:
    case DNS_TYPE_CNAME:
    case DNS_TYPE_PTR:
        offset = (pkt->buf.ptr - pkt->buf.data) - 2;
        if (dnsParseName(pkt, &pkt->buf.ptr, name, 255, 0, 0) < 0) {
            goto err;
        }
        y->data.name = ns_strdup(name);
        break;
    case DNS_TYPE_NAPTR:
        y->data.naptr = ns_calloc(1, sizeof(dnsNAPTR));
        memcpy(&us, pkt->buf.ptr, sizeof(us));
        y->data.naptr->order = ntohs(us);
        pkt->buf.ptr += 2;
        memcpy(&us, pkt->buf.ptr, sizeof(us));
        y->data.mx->preference = ntohs(us);
        pkt->buf.ptr += 2;
        /* flags */
        if (dnsParseString(pkt, &y->data.naptr->flags) < 0) {
            strcpy(name, "invalid NAPTR flags len");
            goto err;
        }
        /* service */
        if (dnsParseString(pkt, &y->data.naptr->service) < 0) {
            strcpy(name, "invalid NAPTR service len");
            goto err;
        }
        /* regexp */
        if (dnsParseString(pkt, &y->data.naptr->regexp) < 0) {
            strcpy(name, "invalid NAPTR regexp len");
            goto err;
        }
        /* replace */
        if (dnsParseName(pkt, &pkt->buf.ptr, name, 255, 0, 0) < 0) {
            goto err;
        }
        y->data.naptr->replace = ns_strdup(name);
        break;
    case DNS_TYPE_SOA:
        y->data.soa = ns_calloc(1, sizeof(dnsSOA));
        /* MNAME */
        if (dnsParseName(pkt, &pkt->buf.ptr, name, 255, 0, 0) < 0) {
            goto err;
        }
        y->data.soa->mname = ns_strdup(name);
        /* RNAME */
        if (dnsParseName(pkt, &pkt->buf.ptr, name, 255, 0, 0) < 0) {
            goto err;
        }
        y->data.soa->rname = ns_strdup(name);
        if (pkt->buf.ptr + 20 > pkt->buf.data + pkt->buf.allocated) {
            strcpy(name, "invalid SOA data len");
            goto err;
        }
        memcpy(&ul, pkt->buf.ptr, sizeof(ul));
        y->data.soa->serial = ntohl(ul);
        pkt->buf.ptr += 4;
        memcpy(&ul, pkt->buf.ptr, sizeof(ul));
        y->data.soa->refresh = ntohl(ul);
        pkt->buf.ptr += 4;
        memcpy(&ul, pkt->buf.ptr, sizeof(ul));
        y->data.soa->retry = ntohl(ul);
        pkt->buf.ptr += 4;
        memcpy(&ul, pkt->buf.ptr, sizeof(ul));
        y->data.soa->expire = ntohl(ul);
        pkt->buf.ptr += 4;
        memcpy(&ul, pkt->buf.ptr, sizeof(ul));
        y->data.soa->ttl = ntohl(ul);
        pkt->buf.ptr += 4;
    }
  rec:
    dnsRecordLog(y, 9, "Record parsed: ");
    return y;
  err:
    {
        dnsRecordLog(y, -1, name);
        dnsRecordFree(y);
    }
    return 0;

}

dnsPacket *dnsParsePacket(unsigned char *packet, int size)
{
    int i;
    dnsPacket *pkt;
    dnsRecord *rec;

    pkt = dnsParseHeader(packet, size);
    for (i = 0; i < pkt->qdcount; i++) {
        if (!(rec = dnsParseRecord(pkt, 1))) {
            goto err;
        }
        dnsRecordAppend(&pkt->qdlist, rec);
    }
    if (!pkt->qdlist)
        goto err;
    for (i = 0; i < pkt->ancount; i++) {
        if (!(rec = dnsParseRecord(pkt, 0))) {
            goto err;
        }
        dnsRecordAppend(&pkt->anlist, rec);
    }
    for (i = 0; i < pkt->nscount; i++) {
        if (!(rec = dnsParseRecord(pkt, 0))) {
            goto err;
        }
        dnsRecordAppend(&pkt->nslist, rec);
    }
    for (i = 0; i < pkt->arcount; i++) {
        if (!(rec = dnsParseRecord(pkt, 0))) {
            goto err;
        }
        dnsRecordAppend(&pkt->arlist, rec);
    }
    return pkt;
  err:
    dnsPacketLog(pkt, -1, "Parse error: ");
    dnsPacketFree(pkt, 2);
    return 0;

}

void dnsEncodeName(dnsPacket * pkt, char *name, int compress)
{
    dnsName *nm;
    unsigned int c;
    int i, k = 0, len;

    dnsEncodeGrow(pkt, (name ? strlen(name) + 1 : 1), "name");
    if (name) {
        while (name[k]) {
            for (len = 0; (c = name[k + len]) != 0 && c != '.'; len++);
            if (!len || len > 63) {
                break;
            }
            // Find already saved domain name
            for (nm = pkt->nmlist; compress && nm; nm = nm->next) {
                if (!strcasecmp(nm->name, &name[k])) {
                    dnsEncodePtr(pkt, nm->offset);
                    return;
                }
            }
            // Save name part for future reference
            nm = (dnsName *) ns_calloc(1, sizeof(dnsName));
            nm->next = pkt->nmlist;
            pkt->nmlist = nm;
            nm->name = ns_strdup(&name[k]);
            nm->offset = (pkt->buf.ptr - pkt->buf.data) - 2;
            // Encode name part inline
            *pkt->buf.ptr++ = (u_char) (len & 0x3F);
            for (i = 0; i < len; i++) {
                *pkt->buf.ptr++ = name[k++];
            }
            if (name[k] == '.') {
                k++;
            }
        }
    }
    *pkt->buf.ptr++ = 0;
}

void dnsEncodeHeader(dnsPacket * pkt)
{
    unsigned short *p = (unsigned short *) pkt->buf.data;

    pkt->buf.size = (pkt->buf.ptr - pkt->buf.data) - 2;
    p[0] = htons(pkt->buf.size);
    p[1] = htons(pkt->id);
    p[2] = htons(pkt->u);
    p[3] = htons(pkt->qdcount);
    p[4] = htons(pkt->ancount);
    p[5] = htons(pkt->nscount);
    p[6] = htons(pkt->arcount);
}

void dnsEncodePtr(dnsPacket * pkt, int offset)
{
    *pkt->buf.ptr++ = 0xC0 | (offset >> 8);
    *pkt->buf.ptr++ = (offset & 0xFF);
}

void dnsEncodeShort(dnsPacket * pkt, int num)
{
    unsigned short us = htons((unsigned short) num);
    memcpy(pkt->buf.ptr, &us, sizeof(us));
    pkt->buf.ptr += 2;
}

void dnsEncodeLong(dnsPacket * pkt, unsigned long num)
{
    unsigned long ul = htonl((unsigned long) num);
    memcpy(pkt->buf.ptr, &ul, sizeof(ul));
    pkt->buf.ptr += 4;
}

void dnsEncodeData(dnsPacket * pkt, void *ptr, int len)
{
    memcpy(pkt->buf.ptr, ptr, (unsigned) len);
    pkt->buf.ptr += len;
}

void dnsEncodeString(dnsPacket * pkt, char *str)
{
    int len = str ? strlen(str) : 0;
    *pkt->buf.ptr++ = len;
    if (len) {
        memcpy(pkt->buf.ptr, str, (unsigned) len);
        pkt->buf.ptr += len;
    }
}

void dnsEncodeBegin(dnsPacket * pkt)
{
    // Mark offset where the record begins
    pkt->buf.rec = pkt->buf.ptr;
    dnsEncodeShort(pkt, 0);
}

void dnsEncodeEnd(dnsPacket * pkt)
{
    unsigned short us = htons(pkt->buf.ptr - pkt->buf.rec - 2);
    memcpy(pkt->buf.rec, &us, sizeof(us));
}

void dnsEncodeRecord(dnsPacket * pkt, dnsRecord * list)
{
    dnsEncodeGrow(pkt, 12, "pkt:hdr");
    for (; list; list = list->next) {
        dnsEncodeName(pkt, list->name, 1);
        dnsEncodeGrow(pkt, 16, "pkt:data");
        dnsEncodeShort(pkt, list->type);
        dnsEncodeShort(pkt, list->class);
        dnsEncodeLong(pkt, list->ttl);
        dnsEncodeBegin(pkt);
        switch (list->type) {
        case DNS_TYPE_A:
            dnsEncodeData(pkt, &list->data.ipaddr, 4);
            break;
        case DNS_TYPE_MX:
            dnsEncodeShort(pkt, list->data.mx->preference);
            dnsEncodeName(pkt, list->data.mx->name, 1);
            break;
        case DNS_TYPE_SOA:
            dnsEncodeName(pkt, list->data.soa->mname, 1);
            dnsEncodeName(pkt, list->data.soa->rname, 1);
            dnsEncodeGrow(pkt, 20, "pkt:soa");
            dnsEncodeLong(pkt, list->data.soa->serial);
            dnsEncodeLong(pkt, list->data.soa->refresh);
            dnsEncodeLong(pkt, list->data.soa->retry);
            dnsEncodeLong(pkt, list->data.soa->expire);
            dnsEncodeLong(pkt, list->data.soa->ttl);
            break;
        case DNS_TYPE_NS:
        case DNS_TYPE_CNAME:
        case DNS_TYPE_PTR:
            dnsEncodeName(pkt, list->data.name, 1);
            break;
        case DNS_TYPE_NAPTR:
            dnsEncodeShort(pkt, list->data.naptr->order);
            dnsEncodeShort(pkt, list->data.naptr->preference);
            dnsEncodeString(pkt, list->data.naptr->flags);
            dnsEncodeString(pkt, list->data.naptr->service);
            dnsEncodeString(pkt, list->data.naptr->regexp);
            dnsEncodeName(pkt, list->data.naptr->replace, 0);
            break;
        }
        dnsEncodeEnd(pkt);
    }
}

void dnsEncodePacket(dnsPacket * pkt)
{
    pkt->buf.ptr = &pkt->buf.data[DNS_HEADER_LEN + 2];
    /* Encode query part */
    dnsEncodeName(pkt, pkt->qdlist->name, 1);
    dnsEncodeShort(pkt, pkt->qdlist->type);
    dnsEncodeShort(pkt, pkt->qdlist->class);
    /* Encode answer records */
    dnsEncodeRecord(pkt, pkt->anlist);
    dnsEncodeRecord(pkt, pkt->nslist);
    dnsEncodeRecord(pkt, pkt->arlist);
    dnsEncodeHeader(pkt);
}

void dnsEncodeGrow(dnsPacket * pkt, unsigned int size, char *proc)
{
    int offset = pkt->buf.ptr - pkt->buf.data;
    int roffset = pkt->buf.rec - pkt->buf.data;
    if (offset + size >= pkt->buf.allocated) {
        pkt->buf.allocated += 256;
        //Ns_Log(Debug,"grow: %x: before: %x, %d,%d,%d",pkt,pkt->buf.data,offset,size,pkt->buf.allocated);
        pkt->buf.data = ns_realloc(pkt->buf.data, pkt->buf.allocated);
        //Ns_Log(Debug,"grow: %s: %x: after: %x, %d,%d,%d",proc,pkt,pkt->buf.data,offset,size,pkt->buf.allocated);
        pkt->buf.ptr = &pkt->buf.data[offset];
        if (pkt->buf.rec) {
            pkt->buf.rec = &pkt->buf.data[roffset];
        }
    }
}

dnsPacket *dnsPacketCreateReply(dnsPacket * req)
{
    dnsRecord *rec;
    dnsPacket *pkt = NULL;

    if (!req || !req->qdlist) {
        return 0;
    }
    pkt = ns_calloc(1, sizeof(dnsPacket));
    pkt->id = req->id;
    DNS_SET_QR(pkt->u, 1);
    DNS_SET_AA(pkt->u, 1);
    DNS_SET_RD(pkt->u, DNS_GET_RD(req->u));
    pkt->buf.allocated = DNS_REPLY_SIZE;
    pkt->buf.data = ns_calloc(1, pkt->buf.allocated);
    //Ns_Log(Debug,"allocr[%d]: %x: %x",getpid(),pkt,pkt->buf.data);
    // Copy query record(s)
    for (rec = req->qdlist; rec; rec = rec->next) {
        dnsPacketAddRecord(pkt, &pkt->qdlist, &pkt->qdcount, dnsRecordCreate(rec));
    }
    return pkt;
}

dnsPacket *dnsPacketCreateQuery(char *name, int type)
{
    dnsPacket *pkt = NULL;

    if (!name) {
        return 0;
    }
    pkt = ns_calloc(1, sizeof(dnsPacket));
    pkt->id = (unsigned long) pkt % (unsigned long) name;
    DNS_SET_RD(pkt->u, 1);
    pkt->buf.allocated = DNS_REPLY_SIZE;
    pkt->buf.data = ns_calloc(1, pkt->buf.allocated);
    //Ns_Log(Debug,"allocq[%d]: %x: %x",getpid(),pkt,pkt->buf.data);
    if (name) {
        dnsRecord *rec = dnsRecordCreateA(name, 0);
        dnsPacketAddRecord(pkt, &pkt->qdlist, &pkt->qdcount, rec);
        if (type) {
            rec->type = type;
        }
    }
    return pkt;
}

void dnsPacketLog(dnsPacket * pkt, int level, char *text, ...)
{
    dnsRecord *y;
    Ns_DString ds;
    va_list ap;

    if (level > dnsDebug) {
        return;
    }
    va_start(ap, text);

    Ns_DStringInit(&ds);
    Ns_DStringPrintf(&ds, "nsdns: ");
    Ns_DStringVPrintf(&ds, text, ap);
    Ns_DStringPrintf(&ds, " HEADER: [%04X] ID=%u, OP=%d, QR=%d, AA=%d, RD=%d, RA=%d, TC=%d, RCODE=%d, "
                     "QUERY=%u, ANSWER=%u, NS=%u, ADDITIONAL=%u, LEN=%d",
                     pkt->u,
                     pkt->id,
                     DNS_GET_OPCODE(pkt->u),
                     DNS_GET_QR(pkt->u),
                     DNS_GET_AA(pkt->u),
                     DNS_GET_RD(pkt->u),
                     DNS_GET_RA(pkt->u),
                     DNS_GET_TC(pkt->u),
                     DNS_GET_RCODE(pkt->u), pkt->qdcount, pkt->ancount, pkt->nscount, pkt->arcount, pkt->buf.size);
    Ns_DStringPrintf(&ds, " QUESTION SECTION: ");
    for (y = pkt->qdlist; y; y = y->next)
        dnsRecordDump(&ds, y);
    Ns_DStringPrintf(&ds, " ANSWER SECTION: ");
    for (y = pkt->anlist; y; y = y->next)
        dnsRecordDump(&ds, y);
    Ns_DStringPrintf(&ds, " NAMESERVER SECTION: ");
    for (y = pkt->nslist; y; y = y->next)
        dnsRecordDump(&ds, y);
    Ns_DStringPrintf(&ds, " ADDITIONAL SECTION: ");
    for (y = pkt->arlist; y; y = y->next)
        dnsRecordDump(&ds, y);
    Ns_Log(level < 0 ? Error : Notice, ds.string);
    Ns_DStringFree(&ds);
}

void dnsPacketFree(dnsPacket * pkt, int type)
{
    if (!pkt) {
        return;
    }
    dnsRecordDestroy(&pkt->qdlist);
    dnsRecordDestroy(&pkt->nslist);
    dnsRecordDestroy(&pkt->arlist);
    dnsRecordDestroy(&pkt->anlist);
    while (pkt->nmlist) {
        dnsName *next = pkt->nmlist->next;
        ns_free(pkt->nmlist->name);
        ns_free(pkt->nmlist);
        pkt->nmlist = next;
    }
    //Ns_Log(Debug,"free[%d]: %d: %x: %x",getpid(),type,pkt,pkt->buf.data);
    ns_free(pkt->buf.data);
    ns_free(pkt);
}

int dnsPacketAddRecord(dnsPacket * pkt, dnsRecord ** list, short *count, dnsRecord * rec)
{
    // Do not allow duplicate or broken records
    if (dnsRecordSearch(*list, rec, 0)) {
        return -1;
    }
    dnsRecordAppend(list, rec);
    (*count)++;
    return 0;
}

int dnsPacketInsertRecord(dnsPacket * pkt, dnsRecord ** list, short *count, dnsRecord * rec)
{
    // Do not allow duplicate or broken records
    if (dnsRecordSearch(*list, rec, 0)) {
        return -1;
    }
    dnsRecordInsert(list, rec);
    (*count)++;
    return 0;
}

const char *dnsTypeStr(int type)
{
    int i = 0;
    while (dnsTypes[i].name) {
      if (type == dnsTypes[i].type) {
          return dnsTypes[i].name;
      }
      i++;
    }
    return "unknown";
}

int dnsType(char *name)
{
    int i = 0;
    while (dnsTypes[i].name) {
      if (!strcasecmp(name, dnsTypes[i].name)) {
          return dnsTypes[i].type;
      }
      i++;
    }
    return -1;
}
