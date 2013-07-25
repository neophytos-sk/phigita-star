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

#ifdef WIN32

#include <winsock2.h>
#include <windows.h>
#include <stdio.h>
#include <string.h>
#include <Iphlpapi.h>

#pragma warning( disable: 4786 )
#pragma warning( disable: 4503 )

#include <string>
#include <list>
using namespace std;

#include "dnsresolv.h"

#pragma pack( push, DNSPacketDef )
#pragma pack( 1 )
struct DNSPacket
{
	unsigned int	nMsgLength;
	unsigned short	Hdr[DNSMSG_HDR_SIZE];
	unsigned char	Data[DNSMSG_MAX_DATA_SIZE];
};

struct SocketInfo
{
	SOCKET			s;
	SOCKADDR_IN		sockaddr;
	list<string>	DNSServers;
};

#pragma pack( pop, DNSPacketDef )


int dn_expand( const u_char *msg, const u_char *eom, 
			   const u_char *src, char *dst, int dstsiz)
{
	char* d = dst;
	u_char* p = (u_char*)src;
	int n = 0;
	int len = -1;

	//OutputDebugString( "dn_expand\n" );

	while( p < eom && *p != 0)
	{
		if ((*p & DNSMSG_COMPRESS_FLAG) == DNSMSG_COMPRESS_FLAG ) 
		{
			p++;
			if( len == -1 )
				len = p - src + 1;

			p = (u_char*)(msg + (((p[-1] & 0x3f) << 8) | (*p & 0xff)));

			if( p < msg || p > eom )
			{
				return -1;
			}
		}
		else if ((*p & DNSMSG_COMPRESS_FLAG) != 0 ) 
		{
			return -1;
		}

		n = *p++;

		while( p < eom && n > 0 )
		{
			if( *p == 0x22 || *p == 0x2E || *p == 0x3B || *p == 0x5C || *p == 0x40 || *p == 0x24 )
			{
				*d++ = '\\';
				*d++ = *p;
			}
			else if( *p > 0x20 && *p < 0x7f )
			{
				*d++ = *p;
			}
			else
			{
				*d++ = '\\';
				*d++ = '0'  + *p / 100;
				*d++ = '0' + *p % 100;
				*d++ = '0' + *p % 10;
			}

			p++;
			n--;
		}
		*d++ = '.';
	}

	if( d[-1] == '.' )
		d[-1] = '\0';
	else
		*d = 0;
	
	if( len == -1 )
		len = p - src + 1;

	return (len);
}


void SwapHeader( struct DNSPacket* pkt )
{
#if BYTE_ORDER == LITTLE_ENDIAN
	int i;
	for( i = 0; i < DNSMSG_HDR_SIZE; i++ )
	{
		unsigned char* p = (unsigned char*)(&pkt->Hdr[i]);
		unsigned char b = p[0];
		p[0] = p[1];
		p[1] = b;
	}
#endif
}

void AddShort( char** ptr, unsigned short s )
{
	unsigned char* p = (unsigned char*)&s;
#if BYTE_ORDER == LITTLE_ENDIAN
	*(*ptr) = p[1];
	(*ptr)++;
	*(*ptr) = p[0];
	(*ptr)++;
#else
	*(*ptr) = p[0];
	(*ptr)++;
	*(*ptr) = p[1];
	(*ptr)++;
#endif
}

int InitDNSPacket( struct DNSPacket* pkt, const char* name, int iclass, int itype )
{
	char szLabel[DNSMSG_MAX_LABEL];
	char* n = (char*)name;
	char* lastdot = NULL;
	char* s = szLabel;
	char* p;
	char backslash = 0;
	int nLabelLen = 0;

	ZeroMemory( pkt, sizeof(struct DNSPacket) );
	pkt->Hdr[DNSMSG_HDR_ID] = 0;
	pkt->Hdr[DNSMSG_HDR_CODES] = 0x100; 
	pkt->Hdr[DNSMSG_HDR_QDCOUNT] = 1;
	pkt->Hdr[DNSMSG_HDR_ANCOUNT] = 0;
	pkt->Hdr[DNSMSG_HDR_NSCOUNT] = 0;
	pkt->Hdr[DNSMSG_HDR_ARCOUNT] = 0;

	SwapHeader( pkt );

	p = (char*)pkt->Data;

	pkt->nMsgLength = 0;

	while( *n )
	{
		if( backslash )
		{
			int nChar;
			if( *n >= '0' && *n <= '9' )
			{
				nChar = 100 * (int)(*n - '0');
				n++;
				if( *n < '0' || *n > '9' )
				{
						return EMSGSIZE; //invalid escape code
				}
				nChar += 10 * (int)(*n - '0');
				n++;
				if( *n < '0' || *n > '9' )
				{
						return EMSGSIZE; //invalid escape code
				}
				nChar += (int)(*n - '0');

				if( (s - szLabel + 1) < DNSMSG_MAX_LABEL )
				{
					*s = (char) nChar;
					s++;
				}
				else
				{
					return EMSGSIZE;
				}
			}
			else 
			{
				if( (s - szLabel + 1) < DNSMSG_MAX_LABEL )
				{
					*s = (char) *n;
					s++;
				}
				else
				{
					return EMSGSIZE;
				}
			}

			backslash = 0;
		}
		else if( *n == '\\' )
		{
			// enter escape mode
			backslash = 1;
		}
		else if( *n == '.' )
		{
			nLabelLen = (s - szLabel);
			//*s = 0;
			*p++ = nLabelLen;
			memcpy( p, szLabel, nLabelLen);
			p += nLabelLen;
			s = szLabel;

			if( n[1] == '\0' )
			{
				*p++ = 0;
				// Type
				*p++ = 0;
				*p++ = T_TXT;
				// Class
				*p++ = 0;
				*p++ = C_IN;

				pkt->nMsgLength = (u_char*)p - pkt->Data + DNSMSG_HDR_SIZE * 2;

				return 0;
			}
		}
		else
		{
			// normal char
			if( (s - szLabel + 1) < DNSMSG_MAX_LABEL )
			{
				*s = *n;
				s++;
			}
			else
			{
				return EMSGSIZE;
			}
		}

		n++;
	}

	nLabelLen = (s - szLabel);
	if( nLabelLen > 0 )
	{
		*p++ = nLabelLen;
		memcpy( p, szLabel, nLabelLen);
		p += nLabelLen;
	}

	*p++ = 0;
	// Type
	AddShort( &p, T_TXT );
	// Class
	AddShort( &p, C_IN );

	pkt->nMsgLength = (u_char*)p - pkt->Data + DNSMSG_HDR_SIZE * 2;

	return 0;
}


void SaveDNSServer( struct SocketInfo* skt, char* szIPAddress )
{
	skt->DNSServers.push_back( szIPAddress );
}


bool GetInternalDNSServer( struct SocketInfo* skt )
{
	char IP[256];
	char buffer[256];
	buffer[0] = '\0';
	int IPSize = sizeof(IP);

	typedef DWORD (WINAPI *LPGETNETWORKPARAMS)(PFIXED_INFO pFixedInfo, PULONG pOutBufLen);
	static LPGETNETWORKPARAMS pGetNetworkParams = (LPGETNETWORKPARAMS)-1;
	static HMODULE hIpHelperDll = NULL;

	if (pGetNetworkParams == (LPGETNETWORKPARAMS)-1)
	{
		hIpHelperDll = LoadLibrary("iphlpapi.dll");
		if (hIpHelperDll != NULL)
			pGetNetworkParams = (LPGETNETWORKPARAMS)GetProcAddress(hIpHelperDll, "GetNetworkParams");
		else
			pGetNetworkParams = NULL;
		// keep the DLL loaded 
	}

	if (pGetNetworkParams != NULL)
	{
		char fibuffer[2048];
		FIXED_INFO &fi = *(FIXED_INFO*)fibuffer;
		ULONG size = sizeof(fibuffer);
		DWORD dwResult = pGetNetworkParams(&fi, &size);
		if (dwResult == ERROR_SUCCESS)
		{
			IP_ADDR_STRING *ip = &fi.DnsServerList;
			while (ip != NULL)
			{
				if (ip->IpAddress.String[0] != '\0')
				{
					strcat(buffer, ip->IpAddress.String);
					strcat(buffer, " ");
				}
				ip = ip->Next;
			}
		}
	}

	// if that didn't work, try reading from the registry
	if (buffer[0] == '\0')
	{
		HKEY hRegKey = NULL;
		if (GetVersion() & 0x80000000)
			RegOpenKeyEx(HKEY_LOCAL_MACHINE, "System\\CurrentControlSet\\Services\\VxD\\MSTCP", 0, KEY_QUERY_VALUE, &hRegKey);
		else
			RegOpenKeyEx(HKEY_LOCAL_MACHINE, "System\\CurrentControlSet\\Services\\TCPIP\\Parameters", 0, KEY_QUERY_VALUE, &hRegKey);
		if (hRegKey != NULL)
		{
			ULONG size = sizeof(buffer);
			RegQueryValueEx(hRegKey, "NameServer", NULL, NULL, (BYTE*)buffer, &size);
			if (buffer[0] == '\0')
			{
				size = sizeof(buffer);
				RegQueryValueEx(hRegKey, "DhcpNameServer", NULL, NULL, (BYTE*)buffer, &size);
			}
			RegCloseKey(hRegKey);
		}

		// look for encoded DNS servers on Win95
		if (buffer[0] == '\0' && RegOpenKeyEx(HKEY_LOCAL_MACHINE, "System\\CurrentControlSet\\Services\\VxD\\DHCP\\DHCPInfo00", 0, KEY_QUERY_VALUE, &hRegKey) == ERROR_SUCCESS)
		{
			unsigned char binbuffer[1024];
			ULONG size = sizeof(binbuffer);
			if (RegQueryValueEx(hRegKey, "OptionInfo", NULL, NULL, binbuffer, &size) == ERROR_SUCCESS)
			{
				unsigned char *ptr = binbuffer;
				while (ptr <= binbuffer+size-2)
				{
					unsigned type = ptr[0];
					unsigned len = ptr[1];
					ptr += 2;
					if (type == 6)
					{
						while (len >= 4)
						{
							sprintf(buffer+strlen(buffer), "%d.%d.%d.%d ", ptr[0], ptr[1], ptr[2], ptr[3]);
							ptr += 4;
							len -= 4;
						}
						break;
					}
					ptr += len;
				}
			}
			RegCloseKey(hRegKey);
		}
	}

	int i = 0;
	char *ptr = buffer;
	for (;;)
	{
		while (*ptr == ' ' || *ptr == ',' || *ptr == ';')
			ptr++;
		if (*ptr == '\0')
			break;

		char *start = ptr;

		for (;;)
		{
			ptr++;
			if (*ptr == '\0')
			{
				break;
			}
			else if (*ptr == ' ' || *ptr == ',' || *ptr == ';')
			{
				*ptr++ = '\0';
				break;
			}
		}

		strncpy(IP, start, IPSize-1);
		IP[IPSize-1] = '\0';

		SaveDNSServer( skt, IP );
	}

	return (skt->DNSServers.size() > 0);
}

int InitWinsock( struct SocketInfo* skt )
{
	WSADATA wsaData;
	WORD wVersionRequested = MAKEWORD(1, 1);
	int nResult;

	nResult = WSAStartup( wVersionRequested, &wsaData );

	if( nResult != 0 )
	{
		return -1;
	}

	if( !GetInternalDNSServer( skt ) )
	{
		return -2;
	}

	ZeroMemory( &skt->sockaddr, sizeof(SOCKADDR_IN) );

	skt->sockaddr.sin_family = AF_INET;
	skt->sockaddr.sin_port = htons(53);
	skt->sockaddr.sin_addr.s_addr = 0xff000001;

	skt->s = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);

	return 0;
}

int SendPacket( struct DNSPacket* pkt, struct SocketInfo* skt )
{

	int nRet;


	nRet = sendto( skt->s, (const char*)pkt->Hdr, pkt->nMsgLength, 0, 
			           (SOCKADDR*)&skt->sockaddr, sizeof(SOCKADDR_IN) );

	if( nRet > 0 )
		return 0;

	return -1;
}


int ReceivePacket( u_char* answer, int anslen, struct SocketInfo* skt )
{
	int nRet;
	fd_set	fdread;
	struct timeval tTimeout;

	FD_ZERO(&fdread);				// zero out set first
	FD_SET( skt->s, &fdread);	// add socket to set

	tTimeout.tv_sec = 3;	// 10 seconds
	tTimeout.tv_usec = 0;	// 0 milliseconds

	// check socket for readability
	nRet = select( skt->s, &fdread, NULL, NULL, &tTimeout);

	if ( nRet < 1 )
	{
		// Retry?

		return -1;
	}

	nRet = recvfrom( skt->s, (char*)answer, anslen, 0, NULL, NULL);
	if( nRet > 0 )
	{
		//char szMsg[80];
		//sprintf( szMsg, "received %d bytes\n", nRet );
		//OutputDebugString( szMsg );

		/*
		{
			FILE* fp = fopen( "out.bin", "wb" );
			if( fp )
			{
				fwrite( answer, 1, anslen, fp );
				fclose(fp );
			}
		}*/

		return nRet;
	}
	
	return -1;
}

void Cleanup( struct SocketInfo* skt )
{
	closesocket( skt->s );

	WSACleanup();
}


int UDPQuery( struct DNSPacket* pkt, struct SocketInfo* skt, u_char* answer, int anslen )
{
	list<string>::iterator DnsIter;
	int nRet = -1;

	for( DnsIter = skt->DNSServers.begin(); DnsIter != skt->DNSServers.end(); DnsIter++ )
	{
		unsigned long nIPAddr = inet_addr( DnsIter->c_str() );

		if( nIPAddr == INADDR_NONE )
		{
			nRet = -1;
		}
		else
		{
			skt->sockaddr.sin_addr.s_addr = nIPAddr;

			nRet = SendPacket( pkt, skt );

			if( nRet != 0 )
			{
				// Error sending packet
				return -1;
			}

			nRet = ReceivePacket( answer, anslen, skt );

			if( nRet > 0 )
			{
				break;
			}
		}
	}

	return nRet;
}

int TCPQuery( struct DNSPacket* pkt, struct SocketInfo* skt, u_char* answer, int anslen )
{
	list<string>::iterator DnsIter;
	int nRet = -1;

	for( DnsIter = skt->DNSServers.begin(); DnsIter != skt->DNSServers.end(); DnsIter++ )
	{
		unsigned long nIPAddr = inet_addr( DnsIter->c_str() );

		if( nIPAddr == INADDR_NONE )
		{
			nRet = -1;
		}
		else
		{
			skt->sockaddr.sin_addr.s_addr = nIPAddr;

			closesocket( skt->s );

			skt->s = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);

			nRet = connect( skt->s, (sockaddr*)&skt->sockaddr, sizeof(struct sockaddr_in) );

			if( nRet == 0 )
			{
				unsigned char nPktLen[2];
				
				nPktLen[1] = pkt->nMsgLength & 0xff;
				nPktLen[0] = (pkt->nMsgLength & 0xff00) >> 8;

				// send the message length
				nRet = send( skt->s, (const char*) &nPktLen, 2, 0 );

				nRet = send( skt->s, (const char*) pkt->Hdr, pkt->nMsgLength, 0 );

				if( nRet > 0 )
				{
					fd_set	fdread;
					struct timeval tTimeout;

					FD_ZERO(&fdread);				// zero out set first
					FD_SET( skt->s, &fdread);	// add socket to set

					tTimeout.tv_sec = 3;	// 10 seconds
					tTimeout.tv_usec = 0;	// 0 milliseconds

					// check socket for readability
					nRet = select( skt->s, &fdread, NULL, NULL, &tTimeout);

					if ( nRet == 1 )
					{
						nRet = recv( skt->s, (char*)nPktLen, 2, 0 );

						if( nRet == 2 )
						{
							unsigned short nResponseLen = nPktLen[0] * 256 + nPktLen[1];

							if( nResponseLen < anslen )
							{
								nRet = recv( skt->s, (char*)answer, anslen, 0 );
							}

						}
						else
						{
							nRet = -1;
						}
					}
				}
				else 
				{
					nRet = -1;
				}
			}

			if( nRet > 0 )
				break;
		}
	}
	

	return nRet;
}



int res_query( const char* name, int iclass, int itype, u_char* answer, int anslen)
{
	struct DNSPacket pkt;
	struct SocketInfo skt;
	int nRet;

	if( iclass != C_IN || itype != T_TXT )
	{
		return -1;
	}

	nRet = InitDNSPacket( &pkt, name, iclass, itype );

	if( nRet != 0 )
	{
		// Error with name
		return -1;
	}

	nRet = InitWinsock( &skt );

	if( nRet != 0 )
	{
		// Error in winsock
		return -1;
	}

	nRet = UDPQuery( &pkt, &skt, answer, anslen );

	if(    ((nRet > 0) && ((answer[2] & 0x02) != 0)) // Check for TrunCation bit
		|| ( nRet == -1 ) )
	{
		nRet = TCPQuery( &pkt, &skt, answer, anslen );
	}

	Cleanup( &skt );

	return nRet;
}

#endif