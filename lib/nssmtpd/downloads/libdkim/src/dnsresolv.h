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

// DNS query routines

#ifndef DNSRESOLV_H
#define DNSRESOLV_H


#define DNSMSG_HDR_ID			0
#define DNSMSG_HDR_CODES		1
#define DNSMSG_HDR_QDCOUNT		2
#define DNSMSG_HDR_ANCOUNT		3
#define DNSMSG_HDR_NSCOUNT		4
#define	DNSMSG_HDR_ARCOUNT		5
#define DNSMSG_HDR_SIZE			6

#define DNSMSG_MAX_LABEL		64
#define DNSMSG_MAX_UDP_SIZE		512
#define DNSMSG_MAX_DATA_SIZE	(DNSMSG_MAX_UDP_SIZE - (DNSMSG_HDR_SIZE*2))

#define DNSMSG_COMPRESS_FLAG	0xc0

#define C_IN		1
#define T_TXT		16

#define EMSGSIZE				1
#define ENOENT					2

typedef unsigned char u_char;
typedef unsigned int u_int;

int	res_query(const char *, int, int, u_char *, int);

int dn_expand(const u_char *, const u_char *, const u_char *, char *, int);

#endif // DNSRESOLV_H