//////////////////////////////////////////////////////////////////////////
//                                                                      //
// XrdClientReadAhead                                                   //
//                                                                      //
// Author: Fabrizio Furano (CERN IT-DM, 2009)                           //
//                                                                      //
// Classes to implement a selectable read ahead decision maker          //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

//         $Id: XrdClientReadAhead.hh 30949 2009-11-02 16:37:58Z ganis $

#ifndef XRD_CLI_READAHEAD
#define XRD_CLI_READAHEAD



class XrdClientReadAheadMgr {
public:
   enum XrdClient_RAStrategy {
      RAStr_none,
      RAStr_pureseq,
      RAStr_SlidingAvg
   };

protected:
   long RASize;
   XrdClient_RAStrategy currstrategy;

public:
      
   static XrdClientReadAheadMgr *CreateReadAheadMgr(XrdClient_RAStrategy strategy);
   

   XrdClientReadAheadMgr() { RASize = 0; };
   virtual ~XrdClientReadAheadMgr() {};

   virtual int GetReadAheadHint(long long offset, long len, long long &raoffset, long &ralen, long blksize) = 0;
   virtual int Reset() = 0;
   virtual void SetRASize(long bytes) { RASize = bytes; };
   
   static bool TrimReadRequest(long long &offs, long &len, long rasize, long blksize);

   XrdClient_RAStrategy GetCurrentStrategy() { return currstrategy; }
};








#endif
