/*****************************************************************************
*  Copyright 2005 Alt-N Technologies, Ltd. 
*
*  Licensed under the Apache License, Version 2.0 (the "License"); 
*  you may not use this file except in compliance with the License. 
*  You may obtain a copy of the License at 
*
*      http://www.apache.org/licenses/LICENSE-2.0 
*
*  This code incorporates intellectual property owned by Yahoo! and licensed 
*  pursuant to the Yahoo! DomainKeys Patent License Agreement.
*
*  Unless required by applicable law or agreed to in writing, software 
*  distributed under the License is distributed on an "AS IS" BASIS, 
*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
*  See the License for the specific language governing permissions and 
*  limitations under the License.
*
*****************************************************************************/

// This file is an intermediary which chooses the correct resolver
// to use based on the platform
//
// Windows 2k+ -> Dynamically load dnsapi.dll and use DnsQuery()
// Win9x/NT    -> Use dnsresolv.cpp
// UNIX        -> Use res_query from libresolv
//
// These DNS resolution routines are encapsulated by the API below

// return values for DNS functions:


#define MAX_DOMAIN			254

#define DNSRESP_SUCCESS					0	// DNS lookup returned sought after records
#define DNSRESP_TEMP_FAIL				1	// No response from DNS server
#define DNSRESP_PERM_FAIL				2	// DNS server returned error or no records
#define DNSRESP_DOMAIN_NAME_TOO_LONG	3	// Domain name too long
#define DNSRESP_NXDOMAIN				4	// DNS server returned Name Error
#define DNSRESP_EMPTY					5	// DNS server returned successful response but no records

// Pass in the FQDN to get the TXT record
int DNSGetTXT( const char *szFQDN, char* Buffer, int nBufLen );
