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

#define DNS_VERSION "0.7.7"

// DNS flags
#define DNS_TCP                 0x0001
#define DNS_PROXY               0x0002
#define DNS_NAPTR_REGEXP        0x0004

//  DNS record types
#define	DNS_HEADER_LEN          12
#define DNS_TYPE_A              1
#define DNS_TYPE_NS             2
#define DNS_TYPE_CNAME          5
#define DNS_TYPE_SOA            6
#define DNS_TYPE_WKS            11
#define DNS_TYPE_PTR            12
#define DNS_TYPE_HINFO          13
#define DNS_TYPE_MINFO          14
#define DNS_TYPE_MX             15
#define DNS_TYPE_TXT            16
#define DNS_TYPE_SRV            33
#define DNS_TYPE_NAPTR          35
#define DNS_TYPE_ANY            255
#define DNS_DEFAULT_TTL         (60 * 60)
#define DNS_CLASS_INET          1

// RCODE types
#define RCODE_NOERROR            0
#define RCODE_QUERYERR           1
#define RCODE_SRVFAIL            2
#define RCODE_NXDOMAIN           3
#define RCODE_NOTIMP             4
#define RCODE_REFUSED            5
#define RCODE_NOTAUTH            9

// OPCODE types
#define OPCODE_QUERY              0
#define OPCODE_IQUERY             1
#define OPCODE_STATUS             2
#define OPCODE_COMPLETION         3
#define OPCODE_NOTIFY             4
#define OPCODE_UPDATE             5

// Macros for manipulating the flags field
#define DNS_GET_RCODE(x)        (((x) & 0x000f))
#define DNS_GET_RA(x)           (((x) & 0x0080) >> 7)
#define DNS_GET_RD(x)           (((x) & 0x0100) >> 8)
#define DNS_GET_TC(x)           (((x) & 0x0200) >> 9)
#define DNS_GET_AA(x)           (((x) & 0x0400) >> 10)
#define DNS_GET_OPCODE(x)       (((x) & 0xe800) >> 11)
#define DNS_GET_QR(x)           (((x) & 0x8000) >> 15)

#define DNS_SET_RCODE(x,y)      ((x) = ((x) & ~0x000f) | ((y) & 0x000f))
#define DNS_SET_RA(x,y)         ((x) = ((x) & ~0x0080) | (((y) << 7) & 0x0080))
#define DNS_SET_RD(x,y)         ((x) = ((x) & ~0x0100) | (((y) << 8) & 0x0100))
#define DNS_SET_TC(x,y)         ((x) = ((x) & ~0x0200) | (((y) << 9) & 0x0200))
#define DNS_SET_AA(x,y)         ((x) = ((x) & ~0x0400) | (((y) << 10) & 0x0400))
#define DNS_SET_OPCODE(x,y)     ((x) = ((x) & ~0xe800) | (((y) << 11) & 0xe800))
#define DNS_SET_QR(x,y)         ((x) = ((x) & ~0x8000) | (((y) << 15) & 0x8000))

#define DNS_BUF_SIZE            2048
#define DNS_REPLY_SIZE          514
#define DNS_QUEUE_SIZE          16

typedef struct _dnsSOA {
    char *mname;
    char *rname;
    unsigned long serial;
    unsigned long refresh;
    unsigned long retry;
    unsigned long expire;
    unsigned long ttl;
} dnsSOA;

typedef struct _dnsMX {
    char *name;
    unsigned short preference;
} dnsMX;

typedef struct _dnsName {
    struct _dnsName *next;
    char *name;
    short offset;
} dnsName;

typedef struct _dnsNAPTR {
    struct _dnsNAPTR *next;
    short order;
    short preference;
    char *flags;
    char *service;
    char *regexp;
    char *regexp_p1;
    char *regexp_p2;
    char *replace;
} dnsNAPTR;

typedef struct _dnsRecord {
    struct _dnsRecord *next,*prev;
    char *name;
    short nsize;
    unsigned short type;
    unsigned short class;
    unsigned long ttl;
    short len;
    union {
      char *name;
      struct in_addr ipaddr;
      dnsMX *mx;
      dnsNAPTR *naptr;
      dnsSOA *soa;
    } data;
    unsigned long timestamp;
    unsigned short rcode;
} dnsRecord;

typedef struct _dnsPacket {
    unsigned short id;
    unsigned short u;
    short qdcount;
    short ancount;
    short nscount;
    short arcount;
    dnsName *nmlist;
    dnsRecord *qdlist;
    dnsRecord *anlist;
    dnsRecord *nslist;
    dnsRecord *arlist;
    struct {
      unsigned short allocated;
      unsigned short size;
      char *rec;
      char *ptr;
      char *data;
    } buf;
} dnsPacket;

extern int dnsDebug;
extern int dnsFlags;
extern int dnsTTL;

int dnsType(char *type);
const char *dnsTypeStr(int type);
void dnsRecordDump(Ns_DString *ds,dnsRecord *y);
void dnsRecordLog(dnsRecord *rec,int level,char *text, ...);
void dnsRecordFree(dnsRecord *pkt);
void dnsRecordDestroy(dnsRecord **pkt);
int dnsRecordSearch(dnsRecord *list,dnsRecord *rec,int replace);
dnsRecord *dnsRecordCreate(dnsRecord *from);
dnsRecord *dnsRecordCreateA(char *name,unsigned long ipaddr);
dnsRecord *dnsRecordCreateNS(char *name,char *data);
dnsRecord *dnsRecordCreateCNAME(char *name,char *data);
dnsRecord *dnsRecordCreatePTR(char *name,char *data);
dnsRecord *dnsRecordCreateMX(char *name,int preference,char *data);
dnsRecord *dnsRecordCreateSOA(char *name,char *mname,char *rname,
                              unsigned long serial,unsigned long refresh,
                              unsigned long retry,unsigned long expire,unsigned long ttl);
dnsRecord *dnsRecordCreateNAPTR(char *name,int order,int preference,char *flags,
                                char *service,char *regexp,char *replace);
Tcl_Obj *dnsRecordCreateTclObj(Tcl_Interp *interp,dnsRecord *drec);
void dnsRecordUpdate(dnsRecord *rec);
dnsRecord *dnsRecordAppend(dnsRecord **list,dnsRecord *pkt);
dnsRecord *dnsRecordInsert(dnsRecord **list,dnsRecord *pkt);
dnsRecord *dnsRecordRemove(dnsRecord **list,dnsRecord *link);
dnsPacket *dnsParseHeader(void *packet,int size);
dnsRecord *dnsParseRecord(dnsPacket *pkt,int query);
dnsPacket *dnsParsePacket(unsigned char *packet,int size);
int dnsParseName(dnsPacket *pkt,char **ptr,char *buf,int len,int pos,int level);
int dnsParseString(dnsPacket *pkt,char **buf);
void dnsEncodeName(dnsPacket *pkt,char *name,int compress);
void dnsEncodeGrow(dnsPacket *pkt,unsigned int size,char *proc);
void dnsEncodeHeader(dnsPacket *pkt);
void dnsEncodePtr(dnsPacket *pkt,int offset);
void dnsEncodeShort(dnsPacket *pkt,int num);
void dnsEncodeLong(dnsPacket *pkt,unsigned long num);
void dnsEncodeData(dnsPacket *pkt,void *ptr,int len);
void dnsEncodeString(dnsPacket *pkt,char *str);
void dnsEncodeObj(dnsPacket *pkt);
void dnsEncodeBegin(dnsPacket *pkt);
void dnsEncodeEnd(dnsPacket *pkt);
void dnsEncodeRecord(dnsPacket *pkt,dnsRecord *list);
void dnsEncodePacket(dnsPacket *pkt);
dnsPacket *dnsPacketCreateReply(dnsPacket *req);
dnsPacket *dnsPacketCreateQuery(char *name,int type);
void dnsPacketLog(dnsPacket *pkt,int level,char *text, ...);
void dnsPacketFree(dnsPacket *pkt,int type);
int dnsPacketAddRecord(dnsPacket *pkt,dnsRecord **list,short *count,dnsRecord *rec);
int dnsPacketInsertRecord(dnsPacket * pkt, dnsRecord ** list, short *count, dnsRecord * rec);
void dnsInit(char *name,...);
dnsPacket *dnsResolve(char *name,int type,char *server,int timeout,int retries);
dnsPacket *dnsLookup(char *name,int type,int *errcode);
