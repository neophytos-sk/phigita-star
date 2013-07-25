#include "commands.h"
#include "sig.h"
#include "auto_qmail.h"
#include "qmail.h"
#include "readwrite.h"
#include "timeoutread.h"
#include "timeoutwrite.h"
#include "stralloc.h"
#include "substdio.h"
#include "config.h"
#include "env.h"
#include "exit.h"
#include "error.h"
#include "str.h"
#include "mess822.h"
#include "tai.h"
#include "caltime.h"
#include "cdb.h"

int timeout = 1200;

int safewrite(fd,buf,len) int fd; char *buf; int len;
{
  int r;
  r = timeoutwrite(timeout,fd,buf,len);
  if (r <= 0) _exit(1);
  return r;
}

char ssoutbuf[512];
substdio ssout = SUBSTDIO_FDBUF(safewrite,1,ssoutbuf,sizeof ssoutbuf);

void flush() { substdio_flush(&ssout); }
void out(s) char *s; { substdio_puts(&ssout,s); }

void die_read() { _exit(1); }
void nomem() { out("451 out of memory (#4.3.0)\r\n"); flush(); _exit(1); }
void die_config() { out("451 unable to read configuration (#4.3.0)\r\n"); flush(); _exit(1); }
void smtp_quit() { out("221 ofmipd.local\r\n"); flush(); _exit(0); }
void smtp_help() { out("214 qmail home page: http://pobox.com/~djb/qmail.html\r\n"); }
void smtp_noop() { out("250 ok\r\n"); }
void smtp_vrfy() { out("252 send some mail, i'll try my best\r\n"); }
void smtp_unimpl() { out("502 unimplemented (#5.5.1)\r\n"); }
void err_syntax() { out("555 syntax error (#5.5.4)\r\n"); }
void err_wantmail() { out("503 MAIL first (#5.5.1)\r\n"); }
void err_wantrcpt() { out("503 RCPT first (#5.5.1)\r\n"); }
void err_qqt() { out("451 qqt failure (#4.3.0)\r\n"); }
void err_cdb() { out("451 unable to read cdb (#4.3.0)\r\n"); }

config_str rewrite = CONFIG_STR;
stralloc idappend = {0};

stralloc addr = {0}; /* will be 0-terminated, if addrparse returns 1 */
stralloc rwaddr = {0};

int addrparse(arg)
char *arg;
{
  int i;
  char ch;
  char terminator;
  int flagesc;
  int flagquoted;
 
  terminator = '>';
  i = str_chr(arg,'<');
  if (arg[i])
    arg += i + 1;
  else { /* partner should go read rfc 821 */
    terminator = ' ';
    arg += str_chr(arg,':');
    if (*arg == ':') ++arg;
    while (*arg == ' ') ++arg;
  }

  if (*arg == '@') while (*arg) if (*arg++ == ':') break;

  if (!stralloc_copys(&addr,"")) nomem();
  flagesc = 0;
  flagquoted = 0;
  for (i = 0;ch = arg[i];++i) { /* copy arg to addr, stripping quotes */
    if (flagesc) {
      if (!stralloc_append(&addr,&ch)) nomem();
      flagesc = 0;
    }
    else {
      if (!flagquoted && (ch == terminator)) break;
      switch(ch) {
        case '\\': flagesc = 1; break;
        case '"': flagquoted = !flagquoted; break;
        default: if (!stralloc_append(&addr,&ch)) nomem();
      }
    }
  }

  if (!rewritehost_addr(&rwaddr,addr.s,addr.len,config_data(&rewrite))) nomem();

  return rwaddr.len < 900;
}

char *fncdb;
int fdcdb;
stralloc cdbresult = {0};

int seenmail = 0;
char *name; /* defined if seenmail; points into cdbresult */

stralloc mailfrom = {0};
stralloc rcptto = {0};

void smtp_helo(arg) char *arg;
{
  seenmail = 0;
  out("250 ofmipd.local\r\n");
}
void smtp_ehlo(arg) char *arg;
{
  seenmail = 0;
  out("250-ofmipd.local\r\n250-PIPELINING\r\n250 8BITMIME\r\n");
}
void smtp_rset()
{
  seenmail = 0;
  out("250 flushed\r\n");
}
void smtp_mail(arg) char *arg;
{
  if (!addrparse(arg)) { err_syntax(); return; }

  name = 0;
  if (fncdb) {
    uint32 dlen;
    int r;

    r = cdb_seek(fdcdb,rwaddr.s,rwaddr.len,&dlen);
    if (r == -1) { err_cdb(); return; }
    if (r) {
      if (!stralloc_ready(&cdbresult,(unsigned int) dlen)) nomem();
      cdbresult.len = dlen;
      name = cdbresult.s;
      if (cdb_bread(fdcdb,name,cdbresult.len) == -1) { err_cdb(); return; }
      r = byte_chr(name,cdbresult.len,'\0');
      if (r == cdbresult.len) { err_cdb(); return; }
      if (!stralloc_copyb(&rwaddr,cdbresult.s + r + 1,cdbresult.len - r - 1)) nomem();
    }
  }

  if (!stralloc_copy(&mailfrom,&rwaddr)) nomem();
  if (!stralloc_0(&mailfrom)) nomem();
  if (!stralloc_copys(&rcptto,"")) nomem();
  seenmail = 1;
  out("250 ok\r\n");
}
void smtp_rcpt(arg) char *arg; {
  if (!seenmail) { err_wantmail(); return; }
  if (!addrparse(arg)) { err_syntax(); return; }
  if (!stralloc_0(&rwaddr)) nomem();
  if (!stralloc_cats(&rcptto,"T")) nomem();
  if (!stralloc_cats(&rcptto,rwaddr.s)) nomem();
  if (!stralloc_0(&rcptto)) nomem();
  out("250 ok\r\n");
}

struct qmail qqt;
void put(buf,len) char *buf; int len; { qmail_put(&qqt,buf,len); }
void puts(buf) char *buf; { qmail_puts(&qqt,buf); }

stralloc tmp = {0};
stralloc tmp2 = {0};

void rewritelist(list)
stralloc *list;
{
  if (!rewritehost_list(&tmp,list->s,list->len,config_data(&rewrite))) nomem();
  if (!stralloc_copy(list,&tmp)) nomem();
}

void putlist(name,list)
char *name;
stralloc *list;
{
  if (!list->len) return;
  if (!mess822_quotelist(&tmp,list)) nomem();
  if (!mess822_fold(&tmp2,&tmp,name,78)) nomem();
  put(tmp2.s,tmp2.len);
}

mess822_time datastart;
stralloc datastamp = {0};

mess822_time date;
stralloc to = {0};
stralloc cc = {0};
stralloc nrudt = {0};
stralloc from = {0};
stralloc headersender = {0};
stralloc replyto = {0};
stralloc mailreplyto = {0};
stralloc followupto = {0};

stralloc msgid = {0};
stralloc top = {0};
stralloc bottom = {0};

mess822_header h = MESS822_HEADER;
mess822_action a[] = {
  { "date", 0, 0, 0, 0, &date }
, { "to", 0, 0, 0, &to, 0 }
, { "cc", 0, 0, 0, &cc, 0 }
, { "notice-requested-upon-delivery-to", 0, 0, 0, &nrudt, 0 }
, { "from", 0, 0, 0, &from, 0 }
, { "sender", 0, 0, 0, &headersender, 0 }
, { "reply-to", 0, 0, 0, &replyto, 0 }
, { "mail-reply-to", 0, 0, 0, &mailreplyto, 0 }
, { "mail-followup-to", 0, 0, 0, &followupto, 0 }
, { "message-id", 0, &msgid, 0, 0, 0 }
, { "received", 0, &top, 0, 0, 0 }
, { "delivered-to", 0, &top, 0, 0, 0 }
, { "errors-to", 0, &top, 0, 0, 0 }
, { "return-receipt-to", 0, &top, 0, 0, 0 }
, { "resent-sender", 0, &top, 0, 0, 0 }
, { "resent-from", 0, &top, 0, 0, 0 }
, { "resent-reply-to", 0, &top, 0, 0, 0 }
, { "resent-to", 0, &top, 0, 0, 0 }
, { "resent-cc", 0, &top, 0, 0, 0 }
, { "resent-bcc", 0, &top, 0, 0, 0 }
, { "resent-date", 0, &top, 0, 0, 0 }
, { "resent-message-id", 0, &top, 0, 0, 0 }
, { "bcc", 0, 0, 0, 0, 0 }
, { "return-path", 0, 0, 0, 0, 0 }
, { "apparently-to", 0, 0, 0, 0, 0 }
, { "content-length", 0, 0, 0, 0, 0 }
, { 0, 0, &bottom, 0, 0, 0 }
} ;

void finishheader()
{
  if (!mess822_end(&h)) nomem();

  if (name) from.len = 0;

  rewritelist(&to);
  rewritelist(&cc);
  rewritelist(&nrudt);
  rewritelist(&from);
  rewritelist(&headersender);
  rewritelist(&replyto);
  rewritelist(&mailreplyto);
  rewritelist(&followupto);

  put(top.s,top.len);

  if (!date.known) date = datastart;
  if (!mess822_date(&tmp,&date)) nomem();
  puts("Date: ");
  put(tmp.s,tmp.len);
  puts("\n");

  if (!msgid.len) {
    static int idcounter = 0;

    if (!stralloc_copys(&msgid,"Message-ID: <")) nomem();
    if (!stralloc_catlong(&msgid,date.ct.date.year)) nomem();
    if (!stralloc_catint0(&msgid,date.ct.date.month,2)) nomem();
    if (!stralloc_catint0(&msgid,date.ct.date.day,2)) nomem();
    if (!stralloc_catint0(&msgid,date.ct.hour,2)) nomem();
    if (!stralloc_catint0(&msgid,date.ct.minute,2)) nomem();
    if (!stralloc_catint0(&msgid,date.ct.second,2)) nomem();
    if (!stralloc_cats(&msgid,".")) nomem();
    if (!stralloc_catint(&msgid,++idcounter)) nomem();
    if (!stralloc_cat(&msgid,&idappend)) nomem();
    if (!stralloc_cats(&msgid,">\n")) nomem();
  }
  put(msgid.s,msgid.len);

  putlist("From: ",&from);
  if (!from.len) {
    puts("From: ");
    if (!mess822_quote(&tmp,mailfrom.s,name)) nomem();
    put(tmp.s,tmp.len);
    puts("\n");
  }

  putlist("Sender: ",&headersender);
  putlist("Reply-To: ",&replyto);
  putlist("Mail-Reply-To: ",&mailreplyto);
  putlist("Mail-Followup-To: ",&followupto);
  if (!to.len && !cc.len)
    puts("Cc: recipient list not shown: ;\n");
  putlist("To: ",&to);
  putlist("Cc: ",&cc);
  putlist("Notice-Requested-Upon-Delivery-To: ",&nrudt);

  put(bottom.s,bottom.len);
}

int saferead(fd,buf,len) int fd; char *buf; int len;
{
  int r;
  flush();
  r = timeoutread(timeout,fd,buf,len);
  if (r <= 0) die_read();
  return r;
}

char ssinbuf[1024];
substdio ssin = SUBSTDIO_FDBUF(saferead,0,ssinbuf,sizeof ssinbuf);

stralloc line = {0};
int match;

void blast()
{
  int flagheader = 1;
  int i;

  if (!mess822_begin(&h,a)) nomem();

  for (;;) {
    if (getln(&ssin,&line,&match,'\n') == -1) die_read();
    if (!match) die_read();

    --line.len;
    if (line.len && (line.s[line.len - 1] == '\r')) --line.len;
    if (line.len && (line.s[0] == '.')) {
      --line.len;
      if (!line.len) break;
      for (i = 0;i < line.len;++i) line.s[i] = line.s[i + 1];
    }
    line.s[line.len++] = '\n';

    if (flagheader)
      if (!mess822_ok(&line)) {
        finishheader();
	flagheader = 0;
	if (line.len > 1) put("\n",1);
      }
    if (!flagheader)
      put(line.s,line.len);
    else
      if (!mess822_line(&h,&line)) nomem();
  }

  if (flagheader)
    finishheader();
}

stralloc received = {0};

void smtp_data() {
  struct tai now;
  char *qqx;

  tai_now(&now);
  caltime_utc(&datastart.ct,&now,(int *) 0,(int *) 0);
  datastart.known = 1;
  if (!mess822_date(&datastamp,&datastart)) nomem();
 
  if (!seenmail) { err_wantmail(); return; }
  if (!rcptto.len) { err_wantrcpt(); return; }
  seenmail = 0;
  if (qmail_open(&qqt) == -1) { err_qqt(); return; }
  out("354 go ahead\r\n");
 
  qmail_put(&qqt,received.s,received.len);
  qmail_put(&qqt,datastamp.s,datastamp.len);
  qmail_puts(&qqt,"\n");
  blast();
  qmail_from(&qqt,mailfrom.s);
  qmail_put(&qqt,rcptto.s,rcptto.len);
 
  qqx = qmail_close(&qqt);
  if (!*qqx) { out("250 ok\r\n"); return; }
  if (*qqx == 'D') out("554 "); else out("451 ");
  out(qqx + 1);
  out("\r\n");
}

void safecats(out,in)
stralloc *out;
char *in;
{
  char ch;
  while (ch = *in++) {
    if (ch < 33) ch = '?';
    if (ch > 126) ch = '?';
    if (ch == '(') ch = '?';
    if (ch == ')') ch = '?';
    if (ch == '@') ch = '?';
    if (ch == '\\') ch = '?';
    if (!stralloc_append(out,&ch)) nomem();
  }
}

void received_init()
{
  char *x;

  if (!stralloc_copys(&received,"Received: (ofmipd ")) nomem();
  x = env_get("TCPREMOTEINFO");
  if (x) {
    safecats(&received,x);
    if (!stralloc_append(&received,"@")) nomem();
  }
  x = env_get("TCPREMOTEIP");
  if (!x) x = "unknown";
  safecats(&received,x);
  if (!stralloc_cats(&received,"); ")) nomem();
}

struct commands smtpcommands[] = {
  { "rcpt", smtp_rcpt, 0 }
, { "mail", smtp_mail, 0 }
, { "data", smtp_data, flush }
, { "quit", smtp_quit, flush }
, { "helo", smtp_helo, flush }
, { "ehlo", smtp_ehlo, flush }
, { "rset", smtp_rset, 0 }
, { "help", smtp_help, flush }
, { "noop", smtp_noop, flush }
, { "vrfy", smtp_vrfy, flush }
, { 0, smtp_unimpl, flush }
} ;

void main(argc,argv)
int argc;
char **argv;
{
  sig_pipeignore();

  fncdb = argv[1];
  if (fncdb) {
    fdcdb = open_read(fncdb);
    if (fdcdb == -1) die_config();
  }

  received_init();
  if (leapsecs_init() == -1) die_config();
  if (chdir(auto_qmail) == -1) die_config();
  if (rwhconfig(&rewrite,&idappend) == -1) die_config();

  out("220 ofmipd.local ESMTP\r\n");
  commands(&ssin,&smtpcommands);
  nomem();
}
