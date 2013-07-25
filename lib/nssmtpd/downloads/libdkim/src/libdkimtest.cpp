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
#include <windows.h>
#else
#define strnicmp strncasecmp 
#endif

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <stdlib.h>

#include "dkim.h"
#include "dns.h"


// change these to your selector name, domain name, etc
#define MYSELECTOR	"MDaemon"
#define MYDOMAIN	"bardenhagen.com"
#define MYIDENTITY	"dkimtest@bardenhagen.com"


int DKIM_CALL SignThisHeader(const char* szHeader)
{
	if( strnicmp( szHeader, "X-", 2 ) == 0 )
	{
		return 0;
	}

	return 1;
}


int DKIM_CALL SelectorCallback(const char* szFQDN, char* szBuffer, int nBufLen )
{
	return 0;
}



int main(int argc, char* argv[])
{
	int n;
	char* PrivKeyFile = "test.pem";
	char* MsgFile = "test.msg";
	char* OutFile = "signed.msg";
	int nPrivKeyLen;
	char PrivKey[2048];
	char Buffer[1024];
	int BufLen;
	char szSignature[10024];
	time_t t;
	DKIMContext ctxt;
	DKIMSignOptions opts = {0};

	opts.nHash = DKIM_HASH_SHA1_AND_256;

	time(&t);

	opts.nCanon = DKIM_SIGN_RELAXED;
	opts.nIncludeBodyLengthTag = 1;
	opts.nIncludeQueryMethod = 0;
	opts.nIncludeTimeStamp = 0;
	opts.expireTime = t + 604800;		// expires in 1 week
	strcpy( opts.szSelector, MYSELECTOR );
	strcpy( opts.szDomain, MYDOMAIN );
	strcpy( opts.szIdentity, MYIDENTITY );
	opts.pfnHeaderCallback = SignThisHeader;
	strcpy( opts.szRequiredHeaders, "NonExistant" );
	opts.nIncludeCopiedHeaders = 0;
	opts.nIncludeBodyHash = DKIM_BODYHASH_BOTH;

	int nArgParseState = 0;
	bool bSign = true;

	for( n = 1; n < argc; n++ )
	{
		if( argv[n][0] == '-' && strlen(argv[n]) > 1 )
		{
			switch( argv[n][1] )
			{
			case 'b':		// allman or ietf draft 1 or both
				opts.nIncludeBodyHash = atoi( &argv[n][2] );
				break;

			case 'c':		// canonicalization
				if( argv[n][2] == 'r' )
				{
					opts.nCanon = DKIM_SIGN_RELAXED;
				}
				else if( argv[n][2] == 's' )
				{
					opts.nCanon = DKIM_SIGN_SIMPLE;
				}
				else if( argv[n][2] == 't' )
				{
					opts.nCanon = DKIM_SIGN_RELAXED_SIMPLE;
				}
				else if( argv[n][2] == 'u' )
				{
					opts.nCanon = DKIM_SIGN_SIMPLE_RELAXED;
				}
				break;


			case 'l':		// body length tag
				opts.nIncludeBodyLengthTag = 1;
				break;


			case 'h':
				printf( "usage: \n" );
				return 0;

			case 'i':		// identity 
				if( argv[n][2] == '-' )
				{
					opts.szIdentity[0] = '\0';
				}
				else
				{
					strcpy( opts.szIdentity, argv[n] + 2 );
				}
				break;

			case 'q':		// query method tag
				opts.nIncludeQueryMethod = 1;
				break;

			case 's':		// sign
				bSign = true;
				break;

			case 't':		// timestamp tag
				opts.nIncludeTimeStamp = 1;
				break;

			case 'v':		// verify
				bSign = false;
				break;

			case 'x':		// expire time 
				if( argv[n][2] == '-' )
				{
					opts.expireTime = 0;
				}
				else
				{
					opts.expireTime = t + atoi( argv[n] + 2  );
				}
				break;


			case 'z':		// sign w/ sha1, sha256 or both 
				opts.nHash = atoi( &argv[n][2] );
				break;
			}
		}
		else
		{
			switch( nArgParseState )
			{
			case 0:
				MsgFile = argv[n];
				break;
			case 1:
				PrivKeyFile = argv[n];
				break;
			case 2:
				OutFile = argv[n];
				break;
			}
			nArgParseState++;
		}
	}


	if( bSign )
	{
		FILE* PrivKeyFP = fopen( PrivKeyFile, "r" );

		if ( PrivKeyFP == NULL ) 
		{ 
		  printf( "dkimlibtest: can't open private key file %s\n", PrivKeyFile );
		  exit(1);
		}
		nPrivKeyLen = fread( PrivKey, 1, sizeof(PrivKey), PrivKeyFP );
		if (nPrivKeyLen == sizeof(PrivKey)) { /* TC9 */
		  printf( "dkimlibtest: private key buffer isn't big enough, use a smaller private key or recompile.\n");
		  exit(1);
		}
		PrivKey[nPrivKeyLen] = '\0';
		fclose(PrivKeyFP);


		FILE* MsgFP = fopen( MsgFile, "rb" );

		if ( MsgFP == NULL ) 
		{ 
			printf( "dkimlibtest: can't open msg file %s\n", MsgFile );
			exit(1);
		}

		n = DKIMSignInit( &ctxt, &opts );

		while (1) {
			
			BufLen = fread( Buffer, 1, sizeof(Buffer), MsgFP );

			if( BufLen > 0 )
			{
				DKIMSignProcess( &ctxt, Buffer, BufLen );
			}
			else
			{
				break;
			}
		}

		fclose( MsgFP );
		
		//n = DKIMSignGetSig( &ctxt, PrivKey, szSignature, sizeof(szSignature) );

		char* pSig = NULL;

		n = DKIMSignGetSig2( &ctxt, PrivKey, &pSig );

		strcpy( szSignature, pSig );

		DKIMSignFree( &ctxt );

		FILE* in = fopen( MsgFile, "rb" );
		FILE* out = fopen( OutFile, "wb+" );

		fwrite( szSignature, 1, strlen(szSignature), out );
		fwrite( "\r\n", 1, 2, out );

		while (1) {
			
			BufLen = fread( Buffer, 1, sizeof(Buffer), in );

			if( BufLen > 0 )
			{
				fwrite( Buffer, 1, BufLen, out );
			}
			else
			{
				break;
			}
		}

		fclose( in );
	}
	else
	{
		FILE* in = fopen( MsgFile, "rb" );

		DKIMVerifyOptions vopts = {0};
		vopts.pfnSelectorCallback = NULL; //SelectorCallback;

		n = DKIMVerifyInit( &ctxt, &vopts );

		while (1) {
			
			BufLen = fread( Buffer, 1, sizeof(Buffer), in );

			if( BufLen > 0 )
			{
				DKIMVerifyProcess( &ctxt, Buffer, BufLen );
			}
			else
			{
				break;
			}
		}

		n = DKIMVerifyResults( &ctxt );

		int nSigCount = 0;
		DKIMVerifyDetails* pDetails;
		char szPolicy[512];

		n = DKIMVerifyGetDetails(&ctxt, &nSigCount, &pDetails, szPolicy );

		for ( int i = 0; i < nSigCount; i++)
		{
			printf( "Signature #%d: ", i + 1 );

			if( pDetails[i].nResult >= 0 )
				printf( "Success\n" );
			else
				printf( "Failure\n" );
		}

		DKIMVerifyFree( &ctxt );
	}

	return 0;
}
