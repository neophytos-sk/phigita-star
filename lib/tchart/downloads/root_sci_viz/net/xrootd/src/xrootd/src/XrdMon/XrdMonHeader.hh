/*****************************************************************************/
/*                                                                           */
/*                              XrdMonHeader.hh                              */
/*                                                                           */
/* (c) 2005 by the Board of Trustees of the Leland Stanford, Jr., University */
/*                            All Rights Reserved                            */
/*       Produced by Jacek Becla for Stanford University under contract      */
/*              DE-AC02-76SF00515 with the Department of Energy              */
/*****************************************************************************/

// $Id: XrdMonHeader.hh 24468 2008-06-22 16:47:03Z ganis $

#ifndef XRDMONHEADER_HH
#define XRDMONHEADER_HH

#include "XrdMon/XrdMonCommon.hh"
#include "XrdMon/XrdMonTypes.hh"
#include "XrdXrootd/XrdXrootdMonData.hh"
#include "XrdSys/XrdSysHeaders.hh"

#include <sys/time.h>
#include <vector>
using std::ostream;
using std::vector;

class XrdMonHeader {
public:
    packet_t    packetType()  const { return _header.code; }
    sequen_t    seqNo()       const { return _header.pseq; }
    packetlen_t packetLen()   const { return _header.plen; }
    kXR_int32   stod()        const { return _header.stod; }
    bool        stodChanged(senderid_t senderId) const;
    
    void decode(const char* packet);

private:
    XrdXrootdMonHeader _header;

    static vector<kXR_int32> _prevStod; // prevStod for each senderId
    
    friend ostream& operator<<(ostream& o, 
                               const XrdMonHeader& header);
};

#endif /* XRDMONHEADER_HH */

