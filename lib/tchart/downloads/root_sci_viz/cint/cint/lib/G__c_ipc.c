/********************************************************
* cint/cint/lib/G__c_ipc.c
********************************************************/
#include "cint/cint/lib/G__c_ipc.h"
void G__c_reset_tagtable();
void G__set_c_environment() {
  G__add_compiledheader("cint/cint/lib/ipc/ipcif.h");
  G__c_reset_tagtable();
}
int G__c_dllrev() { return(30051515); }

/* Setting up global function */
static int G__ipc__0_0(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) ftok((char*) G__int(libp->para[0]), (char) G__int(libp->para[1])));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__ipc__0_1(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) shmget((key_t) G__int(libp->para[0]), (int) G__int(libp->para[1])
, (int) G__int(libp->para[2])));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__ipc__0_2(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 67, (long) shmat((int) G__int(libp->para[0]), (char*) G__int(libp->para[1])
, (int) G__int(libp->para[2])));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__ipc__0_3(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) shmdt((char*) G__int(libp->para[0])));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__ipc__0_4(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) shmctl((int) G__int(libp->para[0]), (int) G__int(libp->para[1])
, (struct shmid_ds*) G__int(libp->para[2])));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__ipc__0_5(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) semget((key_t) G__int(libp->para[0]), (int) G__int(libp->para[1])
, (int) G__int(libp->para[2])));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__ipc__0_6(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) semctl((int) G__int(libp->para[0]), (int) G__int(libp->para[1])
, (int) G__int(libp->para[2]), *((union semun*) G__int(libp->para[3]))));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__ipc__0_7(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) semop((int) G__int(libp->para[0]), (struct sembuf*) G__int(libp->para[1])
, (unsigned int) G__int(libp->para[2])));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__ipc__0_8(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) msgget((key_t) G__int(libp->para[0]), (int) G__int(libp->para[1])));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__ipc__0_9(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 73, (long) msgsnd((int) G__int(libp->para[0]), (struct msgbuf*) G__int(libp->para[1])
, (int) G__int(libp->para[2]), (int) G__int(libp->para[3])));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__ipc__0_10(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) msgrcv((int) G__int(libp->para[0]), (struct msgbuf*) G__int(libp->para[1])
, (int) G__int(libp->para[2]), (long) G__int(libp->para[3])
, (int) G__int(libp->para[4])));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__ipc__0_11(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) msgctl((int) G__int(libp->para[0]), (int) G__int(libp->para[1])
, (struct msqid_ds*) G__int(libp->para[2])));
   return(1 || funcname || hash || result7 || libp) ;
}


/*********************************************************
* Global function Stub
*********************************************************/

/*********************************************************
* typedef information setup/
*********************************************************/
void G__c_setup_typetable() {

   /* Setting up typedef entry */
   G__search_typename2("key_t",105,-1,0,-1);
   G__setnewtype(-2,NULL,0);
}

/*********************************************************
* Data Member information setup/
*********************************************************/

   /* Setting up class,struct,union tag member variable */

   /* struct shmid_ds */
static void G__setup_memvarshmid_ds(void) {
   G__tag_memvar_setup(G__get_linked_tagnum(&G__LN_shmid_ds));
   { struct shmid_ds *p; p=(struct shmid_ds*)0x1000; if (p) { }
   G__memvar_setup((void*)((long)(&p->shm_perm)-(long)(p)),117,0,0,G__get_linked_tagnum(&G__LN_ipc_perm),-1,-1,1,"shm_perm=",0,(char*)NULL);
   G__memvar_setup((void*)((long)(&p->shm_segsz)-(long)(p)),105,0,0,-1,-1,-1,1,"shm_segsz=",0,(char*)NULL);
   G__memvar_setup((void*)((long)(&p->shm_atime)-(long)(p)),108,0,0,-1,G__defined_typename("time_t"),-1,1,"shm_atime=",0,(char*)NULL);
   G__memvar_setup((void*)((long)(&p->shm_dtime)-(long)(p)),108,0,0,-1,G__defined_typename("time_t"),-1,1,"shm_dtime=",0,(char*)NULL);
   G__memvar_setup((void*)((long)(&p->shm_ctime)-(long)(p)),108,0,0,-1,G__defined_typename("time_t"),-1,1,"shm_ctime=",0,(char*)NULL);
   G__memvar_setup((void*)((long)(&p->shm_cpid)-(long)(p)),114,0,0,-1,-1,-1,1,"shm_cpid=",0,(char*)NULL);
   G__memvar_setup((void*)((long)(&p->shm_lpid)-(long)(p)),114,0,0,-1,-1,-1,1,"shm_lpid=",0,(char*)NULL);
   G__memvar_setup((void*)((long)(&p->shm_nattch)-(long)(p)),115,0,0,-1,-1,-1,1,"shm_nattch=",0,(char*)NULL);
   }
   G__tag_memvar_reset();
}


   /* union semun */
static void G__setup_memvarsemun(void) {
   G__tag_memvar_setup(G__get_linked_tagnum(&G__LN_semun));
   { union semun *p; p=(union semun*)0x1000; if (p) { }
   G__memvar_setup((void*)((long)(&p->val)-(long)(p)),105,0,0,-1,-1,-1,1,"val=",0,(char*)NULL);
   G__memvar_setup((void*)((long)(&p->buf)-(long)(p)),85,0,0,G__get_linked_tagnum(&G__LN_semid_ds),-1,-1,1,"buf=",0,(char*)NULL);
   G__memvar_setup((void*)((long)(&p->array)-(long)(p)),82,0,0,-1,-1,-1,1,"array=",0,(char*)NULL);
   }
   G__tag_memvar_reset();
}


   /* struct sembuf */
static void G__setup_memvarsembuf(void) {
   G__tag_memvar_setup(G__get_linked_tagnum(&G__LN_sembuf));
   { struct sembuf *p; p=(struct sembuf*)0x1000; if (p) { }
   G__memvar_setup((void*)((long)(&p->sem_num)-(long)(p)),114,0,0,-1,G__defined_typename("ushort"),-1,1,"sem_num=",0,(char*)NULL);
   G__memvar_setup((void*)((long)(&p->sem_op)-(long)(p)),115,0,0,-1,-1,-1,1,"sem_op=",0,(char*)NULL);
   G__memvar_setup((void*)((long)(&p->sem_flg)-(long)(p)),115,0,0,-1,-1,-1,1,"sem_flg=",0,(char*)NULL);
   }
   G__tag_memvar_reset();
}

void G__c_setup_memvar() {
}
/***********************************************************
************************************************************
************************************************************
************************************************************
************************************************************
************************************************************
************************************************************
***********************************************************/

/*********************************************************
* Global variable information setup for each class
*********************************************************/
static void G__cpp_setup_global0() {

   /* Setting up global variables */
   G__resetplocal();

   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"__GNUC__=4",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"__GNUC_MINOR__=3",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"G__IPCDLL_H=0",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"IPC_CREAT=512",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"IPC_EXCL=1024",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"IPC_NOWAIT=2048",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"IPC_RMID=0",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"IPC_SET=1",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"IPC_STAT=2",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"IPC_INFO=3",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"SHM_R=256",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"SHM_W=128",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"SHM_RDONLY=4096",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"SHM_RND=8192",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"SHM_REMAP=16384",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"SHM_LOCK=11",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"SHM_UNLOCK=12",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"SHM_STAT=13",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"SHM_INFO=14",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"GETALL=6",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"SETVAL=8",1,(char*)NULL);
   G__memvar_setup((void*)G__PVOID,112,0,0,-1,-1,-1,1,"SETALL=9",1,(char*)NULL);

   G__resetglobalenv();
}
void G__c_setup_global() {
  G__cpp_setup_global0();
}

/*********************************************************
* Global function information setup for each class
*********************************************************/
static void G__cpp_setup_func0() {
 funcptr_and_voidptr funcptr;
   G__lastifuncposition();

#ifndef ftok
   funcptr._write = (void (*)())ftok;
#else
   funcptr._write = 0;
#endif
   G__memfunc_setup("ftok", 436, G__ipc__0_0, 105, -1, G__defined_typename("key_t"), 0, 2, 1, 1, 0, 
"C - - 0 - pathname c - - 0 - proj", (char*) NULL
, funcptr._read, 0);
#ifndef shmget
   funcptr._write = (void (*)())shmget;
#else
   funcptr._write = 0;
#endif
   G__memfunc_setup("shmget", 648, G__ipc__0_1, 105, -1, -1, 0, 3, 1, 1, 0, 
"i - 'key_t' 0 - key i - - 0 - size i - - 0 - shmflg", (char*) NULL
, funcptr._read, 0);
#ifndef shmat
   funcptr._write = (void (*)())shmat;
#else
   funcptr._write = 0;
#endif
   G__memfunc_setup("shmat", 541, G__ipc__0_2, 67, -1, -1, 0, 3, 1, 1, 0, 
"i - - 0 - shmid C - - 0 - shmaddr i - - 0 - shmflg", (char*) NULL
, funcptr._read, 0);
#ifndef shmdt
   funcptr._write = (void (*)())shmdt;
#else
   funcptr._write = 0;
#endif
   G__memfunc_setup("shmdt", 544, G__ipc__0_3, 105, -1, -1, 0, 1, 1, 1, 0, "C - - 0 - shmaddr", (char*) NULL
, funcptr._read, 0);
#ifndef shmctl
   funcptr._write = (void (*)())shmctl;
#else
   funcptr._write = 0;
#endif
   G__memfunc_setup("shmctl", 651, G__ipc__0_4, 105, -1, -1, 0, 3, 1, 1, 0, 
"i - - 0 - shmid i - - 0 - cmd U 'shmid_ds' - 0 - buf", (char*) NULL
, funcptr._read, 0);
#ifndef semget
   funcptr._write = (void (*)())semget;
#else
   funcptr._write = 0;
#endif
   G__memfunc_setup("semget", 645, G__ipc__0_5, 105, -1, -1, 0, 3, 1, 1, 0, 
"i - 'key_t' 0 - key i - - 0 - nsems i - - 0 - semflg", (char*) NULL
, funcptr._read, 0);
#ifndef semctl
   funcptr._write = (void (*)())semctl;
#else
   funcptr._write = 0;
#endif
   G__memfunc_setup("semctl", 648, G__ipc__0_6, 105, -1, -1, 0, 4, 1, 1, 0, 
"i - - 0 - semid i - - 0 - semnum i - - 0 - cmd u 'semun' - 0 - arg", (char*) NULL
, funcptr._read, 0);
#ifndef semop
   funcptr._write = (void (*)())semop;
#else
   funcptr._write = 0;
#endif
   G__memfunc_setup("semop", 548, G__ipc__0_7, 105, -1, -1, 0, 3, 1, 1, 0, 
"i - - 0 - semid U 'sembuf' - 0 - sops h - - 0 - nsops", (char*) NULL
, funcptr._read, 0);
#ifndef msgget
   funcptr._write = (void (*)())msgget;
#else
   funcptr._write = 0;
#endif
   G__memfunc_setup("msgget", 647, G__ipc__0_8, 105, -1, -1, 0, 2, 1, 1, 0, 
"i - 'key_t' 0 - key i - - 0 - msgflg", (char*) NULL
, funcptr._read, 0);
#ifndef msgsnd
   funcptr._write = (void (*)())msgsnd;
#else
   funcptr._write = 0;
#endif
   G__memfunc_setup("msgsnd", 652, G__ipc__0_9, 73, -1, -1, 0, 4, 1, 1, 0, 
"i - - 0 - msgid U 'msgbuf' - 0 - msgp i - - 0 - msgsz i - - 0 - msgflg", (char*) NULL
, funcptr._read, 0);
#ifndef msgrcv
   funcptr._write = (void (*)())msgrcv;
#else
   funcptr._write = 0;
#endif
   G__memfunc_setup("msgrcv", 658, G__ipc__0_10, 105, -1, -1, 0, 5, 1, 1, 0, 
"i - - 0 - msgid U 'msgbuf' - 0 - msgp i - - 0 - msgsz l - - 0 - msgtyp i - - 0 - msgflg", (char*) NULL
, funcptr._read, 0);
#ifndef msgctl
   funcptr._write = (void (*)())msgctl;
#else
   funcptr._write = 0;
#endif
   G__memfunc_setup("msgctl", 650, G__ipc__0_11, 105, -1, -1, 0, 3, 1, 1, 0, 
"i - - 0 - msgid i - - 0 - cmd U 'msqid_ds' - 0 - buf", (char*) NULL
, funcptr._read, 0);

   G__resetifuncposition();
}

void G__c_setup_func() {
  G__cpp_setup_func0();
}

/*********************************************************
* Class,struct,union,enum tag information setup
*********************************************************/
/* Setup class/struct taginfo */
G__linked_taginfo G__LN_ipc_parm = { "ipc_parm" , 115 , -1 };
G__linked_taginfo G__LN_ipc_perm = { "ipc_perm" , 115 , -1 };
G__linked_taginfo G__LN_shmid_ds = { "shmid_ds" , 115 , -1 };
G__linked_taginfo G__LN_semid_ds = { "semid_ds" , 115 , -1 };
G__linked_taginfo G__LN_msqid_ds = { "msqid_ds" , 115 , -1 };
G__linked_taginfo G__LN_semun = { "semun" , 117 , -1 };
G__linked_taginfo G__LN_sembuf = { "sembuf" , 115 , -1 };
G__linked_taginfo G__LN_msgbuf = { "msgbuf" , 115 , -1 };

/* Reset class/struct taginfo */
void G__c_reset_tagtable() {
  G__LN_ipc_parm.tagnum = -1 ;
  G__LN_ipc_perm.tagnum = -1 ;
  G__LN_shmid_ds.tagnum = -1 ;
  G__LN_semid_ds.tagnum = -1 ;
  G__LN_msqid_ds.tagnum = -1 ;
  G__LN_semun.tagnum = -1 ;
  G__LN_sembuf.tagnum = -1 ;
  G__LN_msgbuf.tagnum = -1 ;
}


void G__c_setup_tagtable() {

   /* Setting up class,struct,union tag entry */
   G__tagtable_setup(G__get_linked_tagnum_fwd(&G__LN_ipc_parm),0,-2,0,(char*)NULL,NULL,NULL);
   G__tagtable_setup(G__get_linked_tagnum_fwd(&G__LN_ipc_perm),0,-2,0,(char*)NULL,NULL,NULL);
   G__tagtable_setup(G__get_linked_tagnum_fwd(&G__LN_shmid_ds),sizeof(struct shmid_ds),-2,0,(char*)NULL,G__setup_memvarshmid_ds,NULL);
   G__tagtable_setup(G__get_linked_tagnum_fwd(&G__LN_semid_ds),0,-2,0,(char*)NULL,NULL,NULL);
   G__tagtable_setup(G__get_linked_tagnum_fwd(&G__LN_msqid_ds),0,-2,0,(char*)NULL,NULL,NULL);
   G__tagtable_setup(G__get_linked_tagnum_fwd(&G__LN_semun),sizeof(union semun),-2,0,(char*)NULL,G__setup_memvarsemun,NULL);
   G__tagtable_setup(G__get_linked_tagnum_fwd(&G__LN_sembuf),sizeof(struct sembuf),-2,0,(char*)NULL,G__setup_memvarsembuf,NULL);
}
void G__c_setup() {
  G__check_setup_version(30051515,"G__c_setup()");
  G__set_c_environment();
  G__c_setup_tagtable();

  G__c_setup_typetable();

  G__c_setup_memvar();

  G__c_setup_global();
  G__c_setup_func();
  return;
}
