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

#include "ns.h"
#include "dns.h"

typedef struct _dnsClient {
    Ns_RWLock lock;
    char ipaddr[16];
    Tcl_HashTable list;
    struct _dnsClient *link;
    unsigned long rcount;
    unsigned short rstats[256];
} dnsClient;

// DNS request
typedef struct _dnsRequest {
    struct _dnsRequest *next, *prev;
    int sock;
    int flags;
    dnsPacket *req;
    dnsPacket *reply;
    dnsClient *client;
    struct sockaddr_in addr;
    unsigned short proxy_id;
    unsigned short proxy_count;
    unsigned long proxy_time;
    struct timeval recv_time;
    struct timeval start_time;
    char buffer[DNS_BUF_SIZE];
    int size;
} dnsRequest;

typedef struct _dnsQueue {
    int id;
    Ns_Cond cond;
    Ns_Mutex lock;
    unsigned long size;
    unsigned long maxsize;
    unsigned long requests;
    unsigned long rtime;
    unsigned long wtime;
    struct _dnsRequest *head;
    struct _dnsRequest *tail;
    struct _dnsRequest *freelist;
} dnsQueue;

static void *dnsRequestCreate(int sock, char *buf, int len);
static void dnsRequestFree(dnsRequest * req);
static int dnsRequestSend(dnsRequest * req);
static int dnsRequestHandle(dnsRequest * req);
static int dnsRequestFind(dnsRequest * req, dnsRecord *qlist);
static void dnsRecordCache(dnsClient * client, dnsRecord ** list);
static int dnsWrite(int sock, void *vbuf, int len);
static int dnsRead(int sock, void *vbuf, int len);
static void DnsPanic(const char *fmt, ...);
static void DnsSegv(int sig);
static int DnsCmd(ClientData arg, Tcl_Interp * interp, int objc, Tcl_Obj * CONST objv[]);
static int DnsInterpInit(Tcl_Interp * interp, void *context);
static int DnsTcpListen(SOCKET sock, void *si, int when);
static void DnsTcpThread(void *arg);
static void DnsProxyThread(void *arg);
static void DnsQueueListenThread(void *arg);
static void DnsQueueRequestThread(void *arg);
static dnsClient *DnsClientFind(char *host, struct in_addr addr);
static dnsClient *DnsClientCreate(char *host);
static void DnsClientLink(char *host, char *host2);
static int DnsClientResolve(char *host, struct in_addr *addr);

static unsigned short dnsID = 0;
static int dnsPort;
static int dnsReadTimeout;
static int dnsWriteTimeout;
static int dnsProxyTimeout;
static int dnsNegativeTTL;
static int dnsCacheTTL;
static int dnsUdpSock;
static int dnsTcpSock;
static int dnsProxyPort;
static int dnsProxySock;
static int dnsThreads;
static int dnsRcvBuf;
static int dnsProxyRetries;
static char *dnsProxyHost;
static char *dnsDefaultHost;
static Ns_Cond dnsProxyCond;
static Ns_Mutex dnsProxyMutex;
static dnsRequest *dnsProxyQueue = 0;
static struct sockaddr_in dnsProxyAddr;
static dnsQueue dnsQueues[DNS_QUEUE_SIZE];
static Ns_RWLock dnsClientLock;
static Tcl_HashTable dnsClientList;
static dnsClient dnsClientDflt;

NS_EXPORT int Ns_ModuleVersion = 1;

NS_EXPORT int Ns_ModuleInit(char *server, char *module)
{
    int n, i;
    char *path, *address;

    Ns_Log(Notice, "nsdns module version %s server: %s", DNS_VERSION, server);

    Ns_RWLockInit(&dnsClientLock);
    Tcl_InitHashTable(&dnsClientList, TCL_ONE_WORD_KEYS);
    memset(&dnsClientDflt, 0, sizeof(dnsClient));
    strcpy(dnsClientDflt.ipaddr, "0.0.0.0");
    Ns_RWLockInit(&dnsClientDflt.lock);
    Tcl_InitHashTable(&dnsClientDflt.list, TCL_STRING_KEYS);
    memset(&dnsQueues, 0, sizeof(dnsQueues));

    path = Ns_ConfigGetPath(server, module, NULL);
    address = Ns_ConfigGetValue(path, "address");

    if (!Ns_ConfigGetInt(path, "flags", &dnsFlags)) {
        dnsFlags = 0;
    }
    if (!Ns_ConfigGetInt(path, "debug", &dnsDebug)) {
        dnsDebug = 0;
    }
    if (!Ns_ConfigGetInt(path, "port", &dnsPort)) {
        dnsPort = 5353;
    }
    if (!Ns_ConfigGetInt(path, "ttl", &dnsTTL)) {
        dnsTTL = 86400;
    }
    if (!Ns_ConfigGetInt(path, "negativettl", &dnsNegativeTTL)) {
        dnsNegativeTTL = 3600;
    }
    if (!Ns_ConfigGetInt(path, "cachettl", &dnsCacheTTL)) {
        dnsCacheTTL = 0;
    }
    if (!Ns_ConfigGetInt(path, "rcvbuf", &dnsRcvBuf)) {
        dnsRcvBuf = 0;
    }
    if (!Ns_ConfigGetInt(path, "readtimeout", &dnsReadTimeout)) {
        dnsReadTimeout = 30;
    }
    if (!Ns_ConfigGetInt(path, "writetimeout", &dnsWriteTimeout)) {
        dnsWriteTimeout = 30;
    }
    if (!Ns_ConfigGetInt(path, "proxytimeout", &dnsProxyTimeout)) {
        dnsProxyTimeout = 3;
    }
    if (!Ns_ConfigGetInt(path, "proxyretries", &dnsProxyRetries)) {
        dnsProxyRetries = 2;
    }
    if (!Ns_ConfigGetInt(path, "threads", &dnsThreads)) {
        dnsThreads = 1;
    }
    dnsDefaultHost = Ns_ConfigGetValue(path, "defaulthost");
    // Resolving dns servers
    dnsInit("nameserver", Ns_ConfigGetValue(path, "nameserver"), 0);

    /* If no port specified it will be just client dns resolver module */
    if (dnsPort > 0) {
        // UDP socket
        if ((dnsUdpSock = Ns_SockListenUdp(address, dnsPort)) == -1) {
            Ns_Log(Error, "nsdns: udp: %s:%d: couldn't create socket: %s", address, dnsPort, strerror(errno));
            return NS_ERROR;
        }
        // TCP socket
        if ((dnsTcpSock = Ns_SockListen(address, dnsPort)) == -1) {
            Ns_Log(Error, "nsdns: tcp: %s:%d: couldn't create socket: %s", address, dnsPort, strerror(errno));
            return NS_ERROR;
        }
        // Use NS callback facility because TCP is not going to be very busy
        Ns_SockCallback(dnsTcpSock, DnsTcpListen, 0, NS_SOCK_READ | NS_SOCK_EXIT | NS_SOCK_EXCEPTION);
        // DNS proxy thread
        if (!Ns_ConfigGetInt(path, "proxyport", &dnsProxyPort)) {
            dnsProxyPort = 53;
        }
        if ((dnsProxyHost = Ns_ConfigGetValue(path, "proxyhost"))) {
            if (Ns_GetSockAddr(&dnsProxyAddr, dnsProxyHost, dnsProxyPort) != NS_OK ||
                (dnsProxySock = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
                close(dnsUdpSock);
                close(dnsTcpSock);
                Ns_Log(Notice, "nsdns: create proxy thread %s:%d: %s", dnsProxyHost, dnsProxyPort, strerror(errno));
                return NS_ERROR;
            }
            Ns_ThreadCreate(DnsProxyThread, 0, 0, 0);
        }
        if (dnsRcvBuf) {
            setsockopt(dnsUdpSock, SOL_SOCKET, SO_RCVBUF, &dnsRcvBuf, sizeof(dnsRcvBuf));
            setsockopt(dnsUdpSock, SOL_SOCKET, SO_SNDBUF, &dnsRcvBuf, sizeof(dnsRcvBuf));
        }
        // Start queue threads
        for (n = 0; n < dnsThreads; n++) {
            dnsQueues[n].id = n;
            // Preallocate SIP tickets
            for (i = 0; i <= dnsThreads * 10; i++) {
                dnsRequest *req = ns_calloc(1, sizeof(dnsRequest));
                req->next = dnsQueues[n].freelist;
                dnsQueues[n].freelist = req;
            }
            Ns_ThreadCreate(DnsQueueRequestThread, &dnsQueues[n], 0, 0);
        }
        // Start listen thread
        Ns_ThreadCreate(DnsQueueListenThread, 0, 0, 0);
    }
    if (dnsDebug) {
        Tcl_SetPanicProc(DnsPanic);
        ns_signal(SIGSEGV, DnsSegv);
        Ns_Log(Notice, "nsdns: SEGV and Panic trapping is activated");
    }
    Ns_MutexSetName2(&dnsProxyMutex, "nsdns", "proxy");
    Ns_Log(Notice, "nsdns: version %s listening on %s:%d, FD %d:%d", DNS_VERSION, address ? address : "0.0.0.0", dnsPort,
           dnsUdpSock, dnsTcpSock);
    Ns_TclRegisterTrace(server, DnsInterpInit, 0, NS_TCL_TRACE_CREATE);
    return NS_OK;
}

/*
 * Add ns_dns commands to interp.
 */
static int DnsInterpInit(Tcl_Interp * interp, void *context)
{
    Tcl_CreateObjCommand(interp, "ns_dns", DnsCmd, NULL, NULL);
    return NS_OK;
}

static void DnsPanic(const char *fmt, ...)
{
    va_list ap;

    va_start(ap, fmt);
    Ns_Log(Error, "nsdns[%d]: panic %p", getpid(), va_arg(ap, char *));
    va_end(ap);
    close(dnsUdpSock);
    close(dnsTcpSock);
    while (1) {
        sleep(1);
    }
}

static void DnsSegv(int sig)
{
    close(dnsUdpSock);
    close(dnsTcpSock);
    Ns_Log(Error, "nsdns: SIGSEGV received %d", getpid());
    while (1) {
        sleep(1);
    }
}

static int DnsCmd(ClientData arg, Tcl_Interp * interp, int objc, Tcl_Obj * CONST objv[])
{
    enum commands {
        cmdAdd, cmdDel, cmdFlush, cmdList, cmdResolve, cmdQueue, cmdLookup, cmdStat, cmdFind,
        cmdClientAdd, cmdClientDel, cmdClientList, cmdClientLink, cmdClientFind, cmdClientStats,
        cmdConfig
    };

    static const char *sCmd[] = {
        "add", "del", "flush", "list", "resolve", "queue", "lookup", "stat", "find",
        "clientadd", "clientdel", "clientlist", "clientlink", "clientfind", "clientstats",
        "config", 0
    };
    int i, cmd;
    struct in_addr addr;
    int argc = objc, argp = 2;
    char tmp[128];
    dnsRecord *drec;
    Tcl_HashEntry *hrec;
    Tcl_HashSearch search;
    unsigned long n, r;
    dnsClient *client = &dnsClientDflt;

    if (objc < 2) {
        Tcl_AppendResult(interp, "wrong # args: should be ns_dns command ?args ...?", 0);
        return TCL_ERROR;
    }
    if (Tcl_GetIndexFromObj(interp, objv[1], sCmd, "command", TCL_EXACT, (int *) &cmd) != TCL_OK)
        return TCL_ERROR;

    switch (cmd) {
    case cmdClientLink:
        if (objc < 4) {
            Tcl_WrongNumArgs(interp, 2, objv, "clientip clientip2");
            return TCL_ERROR;
        }
        DnsClientLink(Tcl_GetString(objv[2]), Tcl_GetString(objv[3]));
        break;

    case cmdClientAdd:
        if (argc < 6) {
            Tcl_WrongNumArgs(interp, 2, objv, "client name type value ?ttl?");
            return TCL_ERROR;
        }
        client = DnsClientFind(Tcl_GetString(objv[2]), addr);
        // Create new client
        if (client == &dnsClientDflt) {
            client = DnsClientCreate(Tcl_GetString(objv[2]));
        }
        argc--;
        argp++;

    case cmdAdd:
        if (argc < 5) {
            Tcl_WrongNumArgs(interp, 2, objv, "name type value ?ttl?");
            return TCL_ERROR;
        }
        switch (dnsType(Tcl_GetString(objv[argp + 1]))) {
        case DNS_TYPE_A:
            drec = dnsRecordCreateA(Tcl_GetString(objv[argp]), inet_addr(Tcl_GetString(objv[argp + 2])));
            if (objc > 5) {
                drec->ttl = atoi(Tcl_GetString(objv[argp + 3]));
            }
            break;
        case DNS_TYPE_MX:
            if (argc < 6) {
                Tcl_WrongNumArgs(interp, 2, objv, "name type preference value ?ttl?");
                return TCL_ERROR;
            }
            drec = dnsRecordCreateMX(Tcl_GetString(objv[argp]), atoi(Tcl_GetString(objv[argp + 2])),
                                     Tcl_GetString(objv[argp + 3]));
            if (argc > 6) {
                drec->ttl = atoi(Tcl_GetString(objv[argp + 4]));
            }
            break;
        case DNS_TYPE_NAPTR:
            if (argc < 9) {
                Tcl_WrongNumArgs(interp, 2, objv, "name type order preference flags service regexp ?replace? ?ttl?");
                return TCL_ERROR;
            }
            drec = dnsRecordCreateNAPTR(Tcl_GetString(objv[argp]), atoi(Tcl_GetString(objv[argp + 2])),
                                        atoi(Tcl_GetString(objv[argp + 3])),
                                        Tcl_GetString(objv[argp + 4]), Tcl_GetString(objv[argp + 5]),
                                        Tcl_GetString(objv[argp + 6]), argc > 9 ? Tcl_GetString(objv[argp + 7]) : 0);
            if (argc > 10) {
                drec->ttl = atoi(Tcl_GetString(objv[argp + 8]));
            }
            break;
        case DNS_TYPE_NS:
            drec = dnsRecordCreateNS(Tcl_GetString(objv[argp]), Tcl_GetString(objv[argp + 2]));
            if (argc > 5) {
                drec->ttl = atoi(Tcl_GetString(objv[argp + 3]));
            }
            break;
        case DNS_TYPE_PTR:
            drec = dnsRecordCreatePTR(Tcl_GetString(objv[argp]), Tcl_GetString(objv[argp + 2]));
            if (argc > 5) {
                drec->ttl = atoi(Tcl_GetString(objv[argp + 3]));
            }
            break;
        case DNS_TYPE_CNAME:
            drec = dnsRecordCreateCNAME(Tcl_GetString(objv[argp]), Tcl_GetString(objv[argp + 2]));
            if (argc > 5) {
                drec->ttl = atoi(Tcl_GetString(objv[argp + 3]));
            }
            break;
        default:
            Tcl_AppendResult(interp, "wrong record type, should be A,MX,PTR,CNAME,NS", 0);
            return TCL_ERROR;
        }
        dnsRecordUpdate(drec);
        dnsRecordCache(client, &drec);
        break;

    case cmdClientDel:
        if (argc < 5) {
            Tcl_WrongNumArgs(interp, 2, objv, "client name type ?value?");
            return TCL_ERROR;
        }
        client = DnsClientFind(Tcl_GetString(objv[2]), addr);
        // Ignore unknown clients
        if (client == &dnsClientDflt) {
            break;
        }
        argc--;
        argp++;

    case cmdDel:
        if (argc < 4) {
            Tcl_WrongNumArgs(interp, 2, objv, "name type ?value?");
            return TCL_ERROR;
        }
        Ns_RWLockWrLock(&client->lock);
        if ((hrec = Tcl_FindHashEntry(&client->list, Tcl_GetStringFromObj(objv[argp], &i)))) {
            int type = dnsType(Tcl_GetString(objv[argp + 1]));
            dnsRecord *list = drec = Tcl_GetHashValue(hrec);
            while (drec) {
                if (drec->type == type) {
                    dnsRecordRemove(&list, drec);
                    dnsRecordFree(drec);
                    if (!(drec = list)) {
                        Tcl_DeleteHashEntry(hrec);
                        break;
                    }
                    continue;
                }
                drec = drec->next;
            }
            // Update rstats
            if (i < sizeof(client->rstats)) {
                client->rstats[i]--;
            }
            client->rcount--;
        }
        Ns_RWLockUnlock(&client->lock);
        break;

    case cmdClientFind:
        if (argc < 4) {
            Tcl_WrongNumArgs(interp, 2, objv, "client name");
            return TCL_ERROR;
        }
        client = DnsClientFind(Tcl_GetString(objv[2]), addr);
        // Ignore unknown clients
        if (client == &dnsClientDflt) {
            break;
        }
        argc--;
        argp++;

    case cmdFind:
        if (argc < 3) {
            Tcl_WrongNumArgs(interp, 2, objv, "name");
            return TCL_ERROR;
        }
        Ns_RWLockWrLock(&client->lock);
        if ((hrec = Tcl_FindHashEntry(&client->list, Tcl_GetString(objv[argp])))) {
            Tcl_SetObjResult(interp, dnsRecordCreateTclObj(interp, Tcl_GetHashValue(hrec)));
        }
        Ns_RWLockUnlock(&client->lock);
        break;

    case cmdClientStats:{
        char *ptr, *stats;
        Ns_RWLockWrLock(&dnsClientLock);
        hrec = Tcl_FirstHashEntry(&dnsClientList, &search);
        while (hrec) {
            client = Tcl_GetHashValue(hrec);
            stats = (char *) Tcl_HashStats(&client->list);
            addr.s_addr = (unsigned long) Tcl_GetHashKey(&dnsClientList, hrec);
            Tcl_AppendElement(interp, ns_inet_ntoa(addr));
            sprintf(tmp, "%lu", client->rcount);
            Tcl_AppendElement(interp, tmp);
            for (ptr = stats; *ptr; ptr++) {
                if (*ptr == '\n') {
                    *ptr = ',';
                }
            }
            Tcl_AppendElement(interp, stats);
            hrec = Tcl_NextHashEntry(&search);
            Tcl_Free(stats);
        }
        Ns_RWLockUnlock(&dnsClientLock);
        break;
    }

    case cmdClientList:
        Ns_RWLockWrLock(&dnsClientLock);
        hrec = Tcl_FirstHashEntry(&dnsClientList, &search);
        while (hrec) {
            addr.s_addr = (unsigned long) Tcl_GetHashKey(&dnsClientList, hrec);
            Tcl_AppendElement(interp, ns_inet_ntoa(addr));
            hrec = Tcl_NextHashEntry(&search);
        }
        Ns_RWLockUnlock(&dnsClientLock);
        break;

    case cmdList:{
        Tcl_Obj *list = Tcl_NewListObj(0, 0);
        if (objc > 2) {
            client = DnsClientFind(Tcl_GetString(objv[2]), addr);
        }
        Ns_RWLockRdLock(&client->lock);
        hrec = Tcl_FirstHashEntry(&client->list, &search);
        while (hrec) {
            Tcl_ListObjAppendElement(interp, list, dnsRecordCreateTclObj(interp, Tcl_GetHashValue(hrec)));
            hrec = Tcl_NextHashEntry(&search);
        }
        Ns_RWLockUnlock(&client->lock);
        Tcl_SetObjResult(interp, list);
        break;
    }

    case cmdFlush:
        if (objc > 2) {
            client = DnsClientFind(Tcl_GetString(objv[2]), addr);
            // Ignore unknown clients
            if (client == &dnsClientDflt) {
                break;
            }
        }
        Ns_RWLockWrLock(&client->lock);
        hrec = Tcl_FirstHashEntry(&client->list, &search);
        while (hrec) {
            drec = Tcl_GetHashValue(hrec);
            dnsRecordDestroy(&drec);
            Tcl_DeleteHashEntry(hrec);
            hrec = Tcl_NextHashEntry(&search);
        }
        client->rcount = 0;
        memset(client->rstats, 0, sizeof(client->rstats));
        Ns_RWLockUnlock(&client->lock);
        break;

    case cmdStat:
        for (n = 0, r = 0, i = 0; i < dnsThreads; i++) {
            n += dnsQueues[i].size;
            r += dnsQueues[i].requests;
            sprintf(tmp, "size%d %lu maxsize%d %lu rtime%d %lu wtime%d %lu requests%d %lu ",
                    i, dnsQueues[i].size, i, dnsQueues[i].maxsize,
                    i, dnsQueues[i].rtime, i, dnsQueues[i].wtime, i, dnsQueues[i].requests);
            Tcl_AppendResult(interp, tmp, 0);
        }
        sprintf(tmp, "total %lu requests %lu", n, r);
        Tcl_AppendResult(interp, tmp, 0);
        break;

    case cmdQueue:{
        char buf[255];
        dnsRequest *req;
        Ns_MutexLock(&dnsProxyMutex);
        for (req = dnsProxyQueue; req; req = req->next) {
            snprintf(buf, sizeof(buf), "%d %s", req->req->id, req->req->qdlist->name);
            Tcl_AppendElement(interp, buf);
        }
        Ns_MutexUnlock(&dnsProxyMutex);
        break;
    }

    case cmdResolve:{
        int i, qtype = 0, timeout = 0;
        char *qserver = "127.0.0.1";
        dnsPacket *reply;

        if (objc < 3) {
            Tcl_WrongNumArgs(interp, 1, objv, "hostname ?-type type? ?-server server? ?-timeout timeout?");
            return TCL_ERROR;
        }
        for (i = 3; i < objc - 1; i += 2) {
            if (!strcmp("-server", Tcl_GetString(objv[i]))) {
                qserver = Tcl_GetString(objv[i + 1]);
            } else
            if (!strcmp("-type", Tcl_GetString(objv[i]))) {
                qtype = dnsType(Tcl_GetString(objv[i + 1]));
            } else
            if (!strcmp("-timeout", Tcl_GetString(objv[i]))) {
                timeout = atoi(Tcl_GetString(objv[i + 1]));
            }
        }
        if ((reply = dnsResolve(Tcl_GetString(objv[2]), qtype, qserver, timeout, 3))) {
            Tcl_Obj *list = Tcl_NewListObj(0, 0);
            Tcl_ListObjAppendElement(interp, list, dnsRecordCreateTclObj(interp, reply->anlist));
            Tcl_ListObjAppendElement(interp, list, dnsRecordCreateTclObj(interp, reply->nslist));
            Tcl_ListObjAppendElement(interp, list, dnsRecordCreateTclObj(interp, reply->arlist));
            Tcl_SetObjResult(interp, list);
            dnsPacketFree(reply, 0);
        }
        break;
    }

    case cmdLookup:{
        int qtype = 0;
        dnsPacket *reply;

        if (objc < 3) {
            Tcl_WrongNumArgs(interp, 1, objv, "hostname ?type?");
            return TCL_ERROR;
        }
        if (objc > 3) {
            qtype = dnsType(Tcl_GetString(objv[3]));
        }
        if ((reply = dnsLookup(Tcl_GetString(objv[2]), qtype, 0))) {
            Tcl_Obj *list = Tcl_NewListObj(0, 0);
            Tcl_ListObjAppendElement(interp, list, dnsRecordCreateTclObj(interp, reply->anlist));
            Tcl_ListObjAppendElement(interp, list, dnsRecordCreateTclObj(interp, reply->nslist));
            Tcl_ListObjAppendElement(interp, list, dnsRecordCreateTclObj(interp, reply->arlist));
            Tcl_SetObjResult(interp, list);
            dnsPacketFree(reply, 0);
        }
        break;
    }

    case cmdConfig:
        for (i = 2; i < objc - 1; i += 2) {
            char *key = Tcl_GetString(objv[i]);
            if (!strcmp("ttl", key) ||
                !strcmp("debug", key) ||
                !strcmp("flags", key) ||
                !strcmp("timeout", key) ||
                !strcmp("retry", key) ||
                !strcmp("failuretimeout", key)) {
                dnsInit(key, atoi(Tcl_GetString(objv[i + 1])));
            } else
            if (!strcmp("nameserver", key)) {
                dnsInit(key, Tcl_GetString(objv[i + 1]));
            }
        }
        break;
    }
    return TCL_OK;
}

static void DnsQueueListenThread(void *arg)
{
    int len = sizeof(struct sockaddr_in);
    dnsRequest *req, buf;
    struct timeval recv_time;
    int id = 0;

    memset(&buf, 0, sizeof(buf));
    Ns_ThreadSetName("nsdns:thread");

    while (1) {
        if ((buf.size = recvfrom(dnsUdpSock, buf.buffer, DNS_BUF_SIZE - 1, 0, (struct sockaddr *) &buf.addr, (socklen_t*)&len)) <= 0) {
            if (dnsDebug > 1) {
                Ns_Log(Notice, "nsdns: recvfrom error: %s", strerror(errno));
            }
            continue;
        }
        buf.buffer[buf.size] = 0;
        gettimeofday(&recv_time, 0);
        if (dnsDebug > 0) {
            Ns_Log(Notice, "nsdns: received %d bytes from %s", buf.size, ns_inet_ntoa(buf.addr.sin_addr));
        }
        /*
         *  Link new job into the queue
         */
        Ns_MutexLock(&dnsQueues[id].lock);
        if ((req = dnsQueues[id].freelist)) {
            dnsQueues[id].freelist = req->next;
            req->next = 0;
        }
        if (!req) {
            req = ns_calloc(1, sizeof(dnsRequest));
        }
        memcpy(req, &buf, sizeof(buf));
        req->recv_time = recv_time;
        if (dnsQueues[id].tail) {
            dnsQueues[id].tail->next = req;
        }
        dnsQueues[id].tail = req;
        if (!dnsQueues[id].head) {
            dnsQueues[id].head = req;
        }
        if (++dnsQueues[id].size > dnsQueues[id].maxsize) {
            dnsQueues[id].maxsize = dnsQueues[id].size;
        }
        dnsQueues[id].requests++;
        Ns_CondBroadcast(&dnsQueues[id].cond);
        Ns_MutexUnlock(&dnsQueues[id].lock);
        if (++id >= dnsThreads) {
            id = 0;
        }
    }
}

static void DnsQueueRequestThread(void *arg)
{
    char buf[32];
    dnsQueue *queue;
    dnsRequest *req;
    struct timeval end_time;
    unsigned long rt, wt;

    queue = (dnsQueue *) arg;
    sprintf(buf, "nsdns:queue:%d", queue->id);
    Ns_Log(Notice, "Starting thread: %s", buf);
    Ns_ThreadSetName(buf);

    Ns_MutexInit(&queue->lock);
    Ns_MutexSetName(&queue->lock, buf);
    Ns_MutexLock(&queue->lock);
    while (1) {
        while (!queue->head) {
            Ns_CondWait(&queue->cond, &queue->lock);
        }
        /*
         *  Unlink first job from the queue
         */
        req = queue->head;
        queue->head = req->next;
        if (queue->tail == req) {
            queue->tail = 0;
        }
        queue->size--;
        Ns_MutexUnlock(&queue->lock);
        rt = wt = 0;
        gettimeofday(&req->start_time, 0);
        req->sock = dnsUdpSock;
        // Allocate request structure
        if ((req->req = dnsParsePacket((unsigned char*)req->buffer, req->size))) {
            // Prepare reply header
            req->reply = dnsPacketCreateReply(req->req);
            req->client = DnsClientFind(0, req->addr.sin_addr);
            switch (dnsRequestHandle(req)) {
            case 1:
                // Proxy will handle request
                req = 0;
                break;
            case 0:
                dnsRequestSend(req);
                dnsPacketFree(req->req, 3);
                dnsPacketFree(req->reply, 4);
                // Update statistics, in milliseconds
                gettimeofday(&end_time, 0);
                rt = (end_time.tv_sec - req->start_time.tv_sec) * 1000 + (end_time.tv_usec - req->start_time.tv_usec) / 1000;
                wt = (req->start_time.tv_sec - req->recv_time.tv_sec) * 1000 + (req->start_time.tv_usec -
                                                                                req->recv_time.tv_usec) / 1000;
                break;
            }
        }
        Ns_MutexLock(&queue->lock);
        // Put request structure back if not handled by proxy
        if (req) {
            req->next = queue->freelist;
            queue->freelist = req;
        }
        if (rt > queue->rtime) {
            queue->rtime = rt;
        }
        if (wt > queue->wtime) {
            queue->wtime = wt;
        }
    }
}

static int DnsTcpListen(SOCKET sock, void *si, int when)
{
    struct {
        SOCKET sock;
        struct sockaddr_in saddr;
    } arg;
    int saddr_len = sizeof(struct sockaddr_in);

    switch (when) {
    case NS_SOCK_READ:
        if ((arg.sock = Ns_SockAccept(sock, (struct sockaddr *) &arg.saddr, &saddr_len)) == INVALID_SOCKET) {
            break;
        }
        if (dnsDebug > 3) {
            Ns_Log(Notice, "DnsTcpListen: connection from %s", ns_inet_ntoa(arg.saddr.sin_addr));
        }
        Ns_ThreadCreate(DnsTcpThread, (void *) &arg, 0, 0);
        return NS_TRUE;
    }
    close(sock);
    return NS_FALSE;
}

static void DnsTcpThread(void *sock)
{
    struct {
        struct sockaddr_in saddr;
        SOCKET sock;
    } arg;
    short len;
    dnsRequest *req;
    char buf[DNS_BUF_SIZE];

    memcpy(&arg, sock, sizeof(arg));
    Ns_SockSetNonBlocking(arg.sock);
    if (dnsRead(arg.sock, &len, 2) != 2 ||
        (len = ntohs(len)) > DNS_BUF_SIZE ||
        dnsRead(arg.sock, buf, len) != len || !(req = dnsRequestCreate(arg.sock, buf, len))) {
        close(arg.sock);
        return;
    }
    req->flags |= DNS_TCP;
    memcpy(&req->addr, &arg.saddr, sizeof(req->addr));
    req->client = DnsClientFind(0, req->addr.sin_addr);
    switch (dnsRequestHandle(req)) {
    case 1:
        /* Request will handled by proxy queue manager */
        break;
    case 0:
        dnsRequestSend(req);
    default:
        dnsRequestFree(req);
    }
    close(arg.sock);
}

static void DnsProxyThread(void *arg)
{
    int len;
    time_t now;
    fd_set rfd;
    dnsRequest *req;
    unsigned short *ptr;
    char buf[DNS_BUF_SIZE + 1];
    struct timeval timeout;
    struct sockaddr_in addr;

    Ns_Log(Notice, "nsdns: proxy thread started, proxy %s(%s):%d FD %d",
           dnsProxyHost, ns_inet_ntoa(dnsProxyAddr.sin_addr), dnsProxyPort, dnsProxySock);

    while (1) {
        Ns_MutexLock(&dnsProxyMutex);
        while (!dnsProxyQueue) {
            Ns_CondWait(&dnsProxyCond, &dnsProxyMutex);
        }
        now = time(0);
        for (req = dnsProxyQueue; req;) {
            if (now - req->proxy_time > dnsProxyTimeout) {
                /* First time, prepare for proxying, use our own id sequence to
                 * keep track of forwarded requests */
                if (!req->proxy_count) {
                    req->proxy_id = req->req->id;
                    req->req->id = ++dnsID;
                    ptr = (unsigned short *) (req->req->buf.data + 2);
                    *ptr = htons(req->req->id);
                }
                /* Reached max request limit, reply with not found code */
                if (req->proxy_count >= dnsProxyRetries) {
                    dnsRequest *next = req->next;
                    if (!req->prev) {
                        dnsProxyQueue = req->next;
                    } else {
                        req->prev->next = req->next;
                    }
                    if (req->next) {
                        req->next->prev = req->prev;
                    }
                    DNS_SET_RCODE(req->reply->u, RCODE_SRVFAIL);
                    req->req->qdlist->rcode = RCODE_SRVFAIL;
                    dnsRecordCache(req->client, &req->req->qdlist);
                    dnsRequestSend(req);
                    dnsRequestFree(req);
                    req = next;
                    continue;
                }
                /* Repeat forwarding request */
                sendto(dnsProxySock,
                       req->req->buf.data + 2,
                       req->req->buf.size, 0, (struct sockaddr *) &dnsProxyAddr, sizeof(struct sockaddr_in));
                req->proxy_count++;
                req->proxy_time = now;
                dnsPacketLog(req->req, 4, "Sending to proxy:");
            }
            req = req->next;
        }
        Ns_MutexUnlock(&dnsProxyMutex);
        timeout.tv_usec = 0;
        timeout.tv_sec = 1;
        FD_ZERO(&rfd);
        FD_SET(dnsProxySock, &rfd);
        if (select(dnsProxySock + 1, &rfd, 0, 0, &timeout) <= 0) {
            continue;
        }
        len = sizeof(struct sockaddr_in);
        if ((len = recvfrom(dnsProxySock, buf, DNS_BUF_SIZE, 0, (struct sockaddr *) &addr, (socklen_t*)&len)) <= 0 ||
            addr.sin_addr.s_addr != dnsProxyAddr.sin_addr.s_addr) {
            if (errno && errno != EAGAIN && errno != EINTR) {
                Ns_Log(Error, "nsdns: recvfrom error %s: %s", ns_inet_ntoa(addr.sin_addr), strerror(errno));
            }
            continue;
        }
        if (dnsDebug > 3) {
            Ns_Log(Notice, "DnsProxyThread: received %d bytes from %s", len, ns_inet_ntoa(dnsProxyAddr.sin_addr));
        }
        Ns_MutexLock(&dnsProxyMutex);
        for (req = dnsProxyQueue; req; req = req->next) {
            // Find request with received ID and remove from the queue
            if (req->req->id == ntohs(*((unsigned short *) buf))) {
                if (!req->prev) {
                    dnsProxyQueue = req->next;
                } else {
                    req->prev->next = req->next;
                }
                if (req->next) {
                    req->next->prev = req->prev;
                }
                break;
            }
        }
        Ns_MutexUnlock(&dnsProxyMutex);
        // Forward reply back to the client and cache locally
        if (req != NULL) {
            *((unsigned short *) buf) = htons(req->proxy_id);
            dnsPacketFree(req->reply, 1);
            if ((req->reply = dnsParsePacket((unsigned char*)buf, len))) {
                dnsPacketLog(req->reply, 6, "Proxy reply received:");
                dnsRequestSend(req);
                /* Save reply in our cache */
                dnsRecordCache(req->client, &req->reply->anlist);
                dnsRecordCache(req->client, &req->reply->nslist);
                dnsRecordCache(req->client, &req->reply->arlist);
            }
            dnsRequestFree(req);
        }
    }
}

static int dnsRead(int sock, void *vbuf, int len)
{
    int nread, n;
    char *buf = (char *) vbuf;
    Ns_Time timeout = { dnsReadTimeout, 0 };

    nread = len;
    while (len > 0) {
        n = Ns_SockRecv(sock, buf, len, &timeout);
        if (n <= 0) {
            return -1;
        }
        len -= n;
        buf += n;
    }
    return nread;
}

static int dnsWrite(int sock, void *vbuf, int len)
{
    int nwrote, n;
    char *buf;
    Ns_Time timeout = { dnsWriteTimeout, 0 };

    nwrote = len;
    buf = vbuf;
    while (len > 0) {
        n = Ns_SockSend(sock, buf, len, &timeout);
        if (n <= 0) {
            return -1;
        }
        len -= n;
        buf += n;
    }
    return nwrote;
}

static void *dnsRequestCreate(int sock, char *buf, int len)
{
    dnsPacket *pkt;
    dnsRequest *req;

    if (!(pkt = dnsParsePacket((unsigned char*)buf, len))) {
        return 0;
    }
    // Allocate request structure
    req = ns_calloc(1, sizeof(dnsRequest));
    req->sock = sock;
    req->req = pkt;
    // Prepare reply header
    req->reply = dnsPacketCreateReply(req->req);
    //Ns_Log(Debug,"ralloc[%d]: %x",getpid(),req);
    return req;
}

static void dnsRequestFree(dnsRequest * req)
{
    if (!req) {
        return;
    }
    //Ns_Log(Debug,"rfree[%d]: %x, %x %x",getpid(),req,req->req,req->reply);
    dnsPacketFree(req->req, 3);
    dnsPacketFree(req->reply, 4);
    ns_free(req);
}

static int dnsRequestFind(dnsRequest * req, dnsRecord *qlist)
{
    int nsize;
    char domain[255], *ptr, *str;
    unsigned long now = time(0);
    Tcl_HashEntry *nrec, *hrec = 0;
    dnsRecord *qrec, *qcache, *ncache, *qstart, *qend;

    for (qrec = qlist; qrec; qrec = qrec->next) {
        if (!qrec->name) {
            continue;
        }
        dnsRecordLog(qrec, 9, "Searching for:");
        nsize = qrec->nsize;
        switch (qrec->type) {
        case DNS_TYPE_NAPTR:
            // Calc how many dots we have in the name
            ptr = qrec->name;
            while (*ptr) {
                // Search only those names that we have in cache
                if (nsize > sizeof(req->client->rstats) || req->client->rstats[nsize]) {
                    if ((hrec = Tcl_FindHashEntry(&req->client->list, ptr))) {
                        break;
                    }
                }
                for (; *ptr && *ptr != '.'; ptr++, nsize--);
                if (*ptr == '.') {
                    ptr++, nsize--;
                }
            }
            if (!hrec) {
                continue;
            }
            break;

        default:
            // Exact and wildcard search
            if (!(hrec = Tcl_FindHashEntry(&req->client->list, qrec->name))) {
                snprintf(domain, sizeof(domain) - 1, "*.%s", qrec->name);
                if (!(hrec = Tcl_FindHashEntry(&req->client->list, domain))) {
                    if (!(ptr = strchr(qrec->name, '.'))) {
                        continue;
                    }
                    snprintf(domain, sizeof(domain) - 1, "*%s", ptr);
                    if (!(hrec = Tcl_FindHashEntry(&req->client->list, domain))) {
                        continue;
                    }
                }
            }
        }
        if (!(qcache = Tcl_GetHashValue(hrec))) {
            continue;
        }
        dnsRecordLog(qcache, 5, "Found cache:");
        qend = 0;
        qstart = qcache;
        while (qcache) {
            if (qrec->type == DNS_TYPE_ANY ||
                qcache->type == DNS_TYPE_CNAME ||
                qcache->type == qrec->type) {
                // This is cached record, verify expiration and remove from the cache if expired
                if (qcache->timestamp && qcache->ttl && qcache->timestamp + qcache->ttl < now) {
                    dnsRecord *next = qcache->next;
                    dnsRecordLog(qcache, 2, "Record expired:");
                    if (qcache->prev) {
                        qcache->prev->next = qcache->next;
                    }
                    if (qcache->next) {
                        qcache->next->prev = qcache->prev;
                    }
                    dnsRecordFree(qcache);
                    if (!qcache->next && !qcache->prev) {
                        Tcl_DeleteHashEntry(hrec);
                        qstart = qend = 0;
                        break;
                    }
                    // First item deleted, update cache entry value
                    if (qcache == qstart) {
                        if ((qstart = next)) {
                            qstart->prev = 0;
                            Tcl_SetHashValue(hrec, qstart);
                        }
                    }
                    qcache = next;
                    continue;
                }
                switch (qcache->type) {
                case DNS_TYPE_CNAME:
                    // Resolve A record for given CNAME, if we have A records in the cache just
                    // return all of them, otherwise let the proxy handle it
                    qrec = dnsRecordCreateA(qcache->data.name, 0);
                    if (dnsRequestFind(req, qrec)) {
                        dnsPacketInsertRecord(req->reply, &req->reply->anlist, &req->reply->ancount, dnsRecordCreate(qcache));
                    }
                    dnsRecordFree(qrec);
                    break;

                case DNS_TYPE_NS:
                    if (qrec->type == DNS_TYPE_NS)
                        dnsPacketAddRecord(req->reply, &req->reply->anlist, &req->reply->ancount,
                                           dnsRecordCreate(qcache));
                    else
                        dnsPacketAddRecord(req->reply, &req->reply->nslist, &req->reply->nscount,
                                           dnsRecordCreate(qcache));

                    // Put IP address of the nameserver into additional section
                    if ((nrec = Tcl_FindHashEntry(&req->client->list, qcache->data.name))) {
                        for (ncache = Tcl_GetHashValue(nrec); ncache; ncache = ncache->next) {
                            if (ncache->type == DNS_TYPE_A) {
                                dnsPacketAddRecord(req->reply, &req->reply->arlist, &req->reply->arcount,
                                                   dnsRecordCreate(ncache));
                            }
                        }
                    }
                    break;

                case DNS_TYPE_NAPTR:
                    // If we found record using wildcard, we have to replace
                    // shorter phone in the regexp with requested from the query
                    if (dnsFlags & DNS_NAPTR_REGEXP && nsize < qrec->nsize && qcache->data.naptr->regexp_p1) {
                        // Create record without regexp, we will build it manually
                        ptr = qcache->data.naptr->regexp;
                        qcache->data.naptr->regexp = 0;
                        ncache = dnsRecordCreate(qcache);
                        qcache->data.naptr->regexp = ptr;
                        // Build regexp from 3 parts
                        ncache->data.naptr->regexp = str = ns_malloc(qrec->nsize + strlen(ptr) + 1);
                        // Before phone
                        for (ptr = qcache->data.naptr->regexp; ptr <= qcache->data.naptr->regexp_p1;) {
                            *str++ = *ptr++;
                        }
                        // Phone itself
                        for (ptr = &qrec->name[qrec->nsize - 1]; ptr >= qrec->name; ptr--) {
                            if (isdigit(*ptr) && (ptr == qrec->name || *(ptr - 1) == '.')) {
                                *str++ = *ptr;
                            }
                        }
                        // After phone
                        for (ptr = qcache->data.naptr->regexp_p2; *ptr;) {
                            *str++ = *ptr++;
                        }
                        *str = 0;
                        dnsPacketAddRecord(req->reply, &req->reply->anlist, &req->reply->ancount, ncache);
                        break;
                    }

                default:
                    // Exact match
                    dnsPacketAddRecord(req->reply, &req->reply->anlist, &req->reply->ancount, dnsRecordCreate(qcache));
                }
                dnsRecordLog(qcache, 4, "Record matched:");
                // Use cached rcode
                if (qcache->rcode) {
                    DNS_SET_RCODE(req->reply->u, qcache->rcode);
                }
            }
            qend = qcache;
            qcache = qcache->next;
        }

        // Do round-robin rotation if we have multiple records
        if (req->reply->ancount && qend && qstart && qend != qstart) {
            qcache = qstart->next;
            qcache->prev = 0;
            qend->next = qstart;
            qstart->prev = qend;
            qstart->next = 0;
            Tcl_SetHashValue(hrec, qcache);
        }
    }

    return req->reply->ancount || req->reply->nscount;
}

static int dnsRequestHandle(dnsRequest * req)
{
    dnsPacketLog(req->req, 1, "Received request from client=%s", req->client->ipaddr);

    switch (DNS_GET_OPCODE(req->req->u)) {
    case OPCODE_QUERY:
        Ns_RWLockRdLock(&req->client->lock);
        dnsRequestFind(req, req->req->qdlist);
        Ns_RWLockUnlock(&req->client->lock);
        // No records found
        if (!req->reply->ancount && !req->reply->nscount) {
            // Put request into proxy queue
            if (dnsProxyHost) {
                Ns_MutexLock(&dnsProxyMutex);
                req->prev = 0;
                req->next = dnsProxyQueue;
                if (req->next) {
                    req->next->prev = req;
                }
                dnsProxyQueue = req;
                Ns_CondBroadcast(&dnsProxyCond);
                Ns_MutexUnlock(&dnsProxyMutex);
                return 1;
            }
            // Default host
            if (dnsDefaultHost) {
                dnsPacketAddRecord(req->reply, &req->reply->anlist, &req->reply->ancount,
                                   dnsRecordCreateA(dnsDefaultHost, inet_addr(dnsDefaultHost)));
                return 0;
            }
            // Otherwise reply with not found reply code
            DNS_SET_RCODE(req->reply->u, RCODE_NXDOMAIN);
        }
        break;

    default:
        // Not supported request
        DNS_SET_RCODE(req->reply->u, RCODE_QUERYERR);
    }
    return 0;
}

static int dnsRequestSend(dnsRequest * req)
{
    int rc;

    dnsEncodePacket(req->reply);
    /* TCP connection requires packet length before the reply packet */
    if (req->flags & DNS_TCP) {
        rc = dnsWrite(req->sock, req->reply->buf.data, req->reply->buf.size + 2);
        dnsPacketLog(req->reply, 5, "Send TCP:");
    } else {
        rc = sendto(req->sock,
                    req->reply->buf.data + 2,
                    req->reply->buf.size, 0, (struct sockaddr *) &req->addr, sizeof(struct sockaddr_in));
        dnsPacketLog(req->reply, 5, "Send UDP:");
    }
    return rc;
}

static void dnsRecordCache(dnsClient * client, dnsRecord ** list)
{
    int flag;
    dnsRecord *drec, *hlist;
    Tcl_HashEntry *hrec;
    unsigned long now = time(0);

    while (*list) {
        drec = *list;
        *list = drec->next;
        drec->timestamp = now;
        drec->next = drec->prev = 0;
        // Cache only if record has ttl and its ttl is less than configured,
        // this is to keep cached records longer
        if (drec->ttl && drec->ttl < dnsCacheTTL) {
            drec->ttl = dnsCacheTTL;
        }
        Ns_RWLockWrLock(&client->lock);
        hrec = Tcl_CreateHashEntry(&client->list, drec->name, &flag);
        if (flag) {
            Tcl_SetHashValue(hrec, drec);
            client->rcount++;
        } else {
            hlist = Tcl_GetHashValue(hrec);
            if (!dnsRecordSearch(hlist, drec, 1)) {
                if ((drec->next = hlist)) {
                    hlist->prev = drec;
                }
                Tcl_SetHashValue(hrec, drec);
            } else {
                dnsRecordFree(drec);
            }
        }
        switch (drec->type) {
        case DNS_TYPE_NAPTR:
            // Update route statistics, mark that we have routes with that length in the cache
            if (drec->nsize < sizeof(client->rstats)) {
                client->rstats[drec->nsize]++;
            }
            break;
        }
        Ns_RWLockUnlock(&client->lock);
    }
}

static dnsClient *DnsClientCreate(char *host)
{
    int new;
    struct in_addr addr;
    dnsClient *client;
    Tcl_HashEntry *entry;

    if (DnsClientResolve(host, &addr) == NS_ERROR) {
        Ns_Log(Error, "DnsClientAdd: unable to resolve %s", host);
        return 0;
    }
    Ns_RWLockWrLock(&dnsClientLock);
    entry = Tcl_CreateHashEntry(&dnsClientList, (char *) addr.s_addr, &new);
    Ns_RWLockUnlock(&dnsClientLock);
    if (new) {
        client = ns_calloc(1, sizeof(dnsClient));
        strcpy(client->ipaddr, ns_inet_ntoa(addr));
        Ns_RWLockInit(&client->lock);
        Tcl_InitHashTable(&client->list, TCL_STRING_KEYS);
        Tcl_SetHashValue(entry, (ClientData) client);
    }
    return Tcl_GetHashValue(entry);
}

static dnsClient *DnsClientFind(char *host, struct in_addr addr)
{
    dnsClient *client;
    Tcl_HashEntry *entry;

    if (host && DnsClientResolve(host, &addr) == NS_ERROR) {
        Ns_Log(Error, "DnsClientClear: unable to resolve %s", host);
        return &dnsClientDflt;
    }
    Ns_RWLockRdLock(&dnsClientLock);
    entry = Tcl_FindHashEntry(&dnsClientList, (char *) addr.s_addr);
    Ns_RWLockUnlock(&dnsClientLock);
    if (entry) {
        client = Tcl_GetHashValue(entry);
        if (client->link) {
            client = client->link;
        }
        return client;
    }
    return &dnsClientDflt;
}

static void DnsClientLink(char *host, char *host2)
{
    dnsClient *client, *client2;

    if ((client = DnsClientCreate(host)) && (client2 = DnsClientCreate(host2))) {
        client2->link = client;
    }
}

static int DnsClientResolve(char *host, struct in_addr *addr)
{
    struct sockaddr_in sa;

    if (!host) {
        host = Ns_InfoHostname();
    }
    if (Ns_GetSockAddr(&sa, host, 0) != NS_OK) {
        return NS_ERROR;
    }
    *addr = sa.sin_addr;
    return NS_OK;
}
