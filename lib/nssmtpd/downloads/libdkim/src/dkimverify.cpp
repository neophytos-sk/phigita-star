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
#pragma warning( disable: 4786 )
#else
#define _strnicmp strncasecmp 
#define _stricmp strcasecmp 
#endif

#include "dkim.h"
#include "dkimverify.h"
#include "dns.h"

#include <string.h>
#include <ctype.h>
#include <assert.h>
#include <vector>
#include <algorithm>

#define MAX_SIGNATURES	10			// maximum number of DKIM signatures to process in a message


SignatureInfo::SignatureInfo(bool s)
{
	VerifiedBodyCount = 0;
	UnverifiedBodyCount = 0;
	EVP_MD_CTX_init( &m_Hdr_ctx );
	EVP_MD_CTX_init( &m_Bdy_ctx );
	m_pSelector = NULL;
	Status = DKIM_SUCCESS;
	m_nHash = 0;
	EmptyLineCount = 0;
	m_SaveCanonicalizedData = s;
}

SignatureInfo::~SignatureInfo()
{
	EVP_MD_CTX_cleanup( &m_Hdr_ctx );
	EVP_MD_CTX_cleanup( &m_Bdy_ctx );
}


inline bool isswsp(char ch)
{
	return( ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n' );
}

////////////////////////////////////////////////////////////////////////////////
// 
// Parse a DKIM tag-list.  Returns true for success
//
////////////////////////////////////////////////////////////////////////////////
bool ParseTagValueList(char *tagvaluelist, const char *wanted[], char *values[])
{
	char *s = tagvaluelist;

	for (;;)
	{
		// skip whitespace
		while (isswsp(*s))
			s++;

		// if at the end of the string, return success.  note: this allows a list with no entries
		if (*s == '\0')
			return true;

		// get tag name
		if (!isalpha(*s))
			return false;

		char *tag = s;
		do {
			s++;
		} while (isalnum(*s) || *s == '-');

		char *endtag = s;

		// skip whitespace before equals
		while (isswsp(*s))
			s++;

		// next character must be equals
		if (*s != '=')
			return false;
		s++;

		// null-terminate tag name
		*endtag = '\0';

		// skip whitespace after equals
		while (isswsp(*s))
			s++;

		// get tag value
		char *value = s;

		while (*s != ';' && ((*s == '\t' || *s == '\r' || *s == '\n') || (*s >= ' ' && *s <= '~')))
			s++;

		char *e = s;

		// make sure the next character is the null terminator (which means we're done) or a semicolon (not done)
		bool done = false;
		if (*s == '\0')
			done = true;
		else
		{
			if (*s != ';')
				return false;
			s++;
		}

		// skip backwards past any trailing whitespace
		while (e > value && isswsp(e[-1]))
			e--;

		// null-terminate tag value
		*e = '\0';

		// check to see if we want this tag
		for (unsigned i=0; wanted[i] != NULL; i++)
		{
			if (strcmp(wanted[i], tag) == 0)
			{
				// return failure if we already have a value for this tag (duplicates not allowed)
				if (values[i] != NULL)
					return false;
				values[i] = value;
				break;
			}
		}

		if (done)
			return true;
	}
}

////////////////////////////////////////////////////////////////////////////////
// 
// Convert hex char to value (0-15)
//
////////////////////////////////////////////////////////////////////////////////
char tohex(char ch)
{
	if (ch >= '0' && ch <= '9')
		return (ch-'0');
	else if (ch >= 'A' && ch <= 'F')
		return (ch-'A'+10);
	else if (ch >= 'a' && ch <= 'f')
		return (ch-'a'+10);
	else
	{
		assert(0);
		return 0;
	}
}

////////////////////////////////////////////////////////////////////////////////
// 
// Decode quoted printable string in-place
//
////////////////////////////////////////////////////////////////////////////////
void DecodeQuotedPrintable(char *ptr)
{
	char *s = ptr;
	while (*s != '\0' && *s != '=')
		s++;

	if (*s == '\0')
		return;

	char *d = s;
	do {
		if (*s == '=' && isxdigit(s[1]) && isxdigit(s[2]))
		{
			*d++ = (tohex(s[1]) << 4) | tohex(s[2]);
			s += 3;
		}
		else
		{
			*d++ = *s++;
		}
	} while (*s != '\0');
	*d = '\0';
}

////////////////////////////////////////////////////////////////////////////////
// 
// Decode base64 string in-place, returns number of bytes output
//
////////////////////////////////////////////////////////////////////////////////
unsigned DecodeBase64(char *ptr)
{
	static const unsigned char base64_table[256] = {
		-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
		-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,62,-1,-1,-1,63,52,53,54,55,56,57,58,59,60,61,-1,-1,-1,-1,-1,-1,
		-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,-1,-1,-1,-1,-1,
		-1,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,-1,-1,-1,-1,-1,
		-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
		-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
		-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
		-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1};

	unsigned char *s = (unsigned char *)ptr;
	unsigned char *d = (unsigned char *)ptr;
	unsigned b64accum=0;
	unsigned char b64shift=0;

	while (*s != '\0')
	{
		unsigned char value = base64_table[*s++];
		if ( (signed char)value >= 0 )
		{
			b64accum = (b64accum << 6) | value;
			b64shift += 6;
			if (b64shift >= 8)
			{
				b64shift -= 8;
				*d++ = (b64accum >> b64shift);
			}
		}
	}

	return (char*)d-ptr;
}

////////////////////////////////////////////////////////////////////////////////
// 
// Match a string with a pattern (used for g= value)
// Supports a single, optional "*" wildcard character.
//
////////////////////////////////////////////////////////////////////////////////
bool WildcardMatch( const char *p, const char *s )
{
	// special case: An empty "g=" value never matches any addresses
	if (*p == '\0')
		return false;

	const char *wildcard = strchr(p, '*');
	if (wildcard == NULL)
	{
		return strcmp(s, p) == 0;
	}
	else
	{
		unsigned beforewildcardlen = wildcard-p;
		unsigned afterwildcardlen = strlen(wildcard+1);
		unsigned slen = strlen(s);
		return (slen >= beforewildcardlen+afterwildcardlen) && 
			(strncmp(s, p, beforewildcardlen) == 0) && strcmp(s+slen-afterwildcardlen, wildcard+1) == 0;
	}
}

////////////////////////////////////////////////////////////////////////////////
// 
// Parse addresses from a string.  Returns true if at least one address found
//
////////////////////////////////////////////////////////////////////////////////
bool ParseAddresses( string str, vector<string> &Addresses )
{
	char *s = (char*) str.c_str();

	while (*s != '\0')
	{
		char *start = s;
		char *from = s;
		char *to = s;
		char *lt = NULL;	// pointer to less than character (<) which starts the address if found

		while (*from != '\0')
		{
			if (*from == '(')
			{
				// skip over comment
				from++;
				for (int depth=1; depth != 0; from++)
				{
					if (*from == '\0')
						break;
					else if (*from == '(')
						depth++;
					else if (*from == ')')
						depth--;
					else if (*from == '\\' && from[1] != '\0')
						from++;
				}
			}
			else if (*from == ')')
			{
				// ignore closing parenthesis outside of comment
				from++;
			}
			else if (*from == ',' || *from == ';')
			{
				// comma/selicolon ends the address
				from++;
				break;
			}
			else if (*from == ' ' || *from == '\t' || *from == '\r' || *from == '\n')
			{
				// ignore whitespace
				from++;
			}
			else if (*from == '"')
			{
				// copy the contents of a quoted string
				from++;
				while (*from != '\0')
				{
					if (*from == '"')
					{
						from++;
						break;
					}
					else if (*from == '\\' && from[1] != '\0')
						*to++ = *from++;
					*to++ = *from++;
				}
			}
			else if (*from == '\\' && from[1] != '\0')
			{
				// copy quoted-pair
				*to++ = *from++;
				*to++ = *from++;
			}
			else
			{
				// copy any other char
				*to = *from++;
				// save pointer to '<' for later...
				if (*to == '<')
					lt = to;
				to++;
			}
		}

		*to = '\0';

		// if there's < > get what's inside
		if (lt != NULL)
		{
			start = lt+1;
			char *gt = strchr(start, '>');
			if (gt != NULL)
				*gt = '\0';
		}
		else
		{
			// look for and strip group name
			char *colon = strchr(start, ':');
			if (colon != NULL)
			{
				char *at = strchr(start, '@');
				if (at == NULL || colon < at)
					start = colon+1;
			}
		}

		if (*start != '\0' && strchr(start, '@') != NULL)
		{
			Addresses.push_back(start);
		}

		s = from;
	}

	return !Addresses.empty();
}


////////////////////////////////////////////////////////////////////////////////


CDKIMVerify::CDKIMVerify()
{
	m_pfnSelectorCallback = NULL;
	m_pfnPracticesCallback = NULL;
	m_HonorBodyLengthTag = false;
	m_CheckPractices = false;
	m_SubjectIsRequired = true;
	m_SaveCanonicalizedData = false;
	m_AllowUnsignedFromHeaders = false;
}

CDKIMVerify::~CDKIMVerify()
{
}

////////////////////////////////////////////////////////////////////////////////
// 
// Init - save the options
//
////////////////////////////////////////////////////////////////////////////////
int CDKIMVerify::Init( DKIMVerifyOptions* pOptions )
{
	int nRet = CDKIMBase::Init();

	m_pfnSelectorCallback = pOptions->pfnSelectorCallback;
	m_pfnPracticesCallback = pOptions->pfnPracticesCallback;

#ifdef WIN32
	if (m_pfnSelectorCallback)
		assert(!IsBadCodePtr( (FARPROC) m_pfnSelectorCallback ));
	if (m_pfnPracticesCallback)
		assert(!IsBadCodePtr( (FARPROC) m_pfnPracticesCallback ));
#endif

	m_HonorBodyLengthTag = pOptions->nHonorBodyLengthTag != 0;
	m_CheckPractices = pOptions->nCheckPractices != 0;
	m_SubjectIsRequired = pOptions->nSubjectRequired == 0;
	m_SaveCanonicalizedData = pOptions->nSaveCanonicalizedData != 0;
	m_AllowUnsignedFromHeaders = pOptions->nAllowUnsignedFromHeaders != 0;

	return nRet;
}

////////////////////////////////////////////////////////////////////////////////
// 
// GetResults - return the pass/fail/neutral verification result
//
////////////////////////////////////////////////////////////////////////////////
int CDKIMVerify::GetResults(void)
{
	ProcessFinal();

	int SuccessCount=0;
	int TestingFailures=0;
	int RealFailures=0;

	list<string> SuccessfulDomains;	// can contain duplicates

	for (list<SignatureInfo>::iterator i = Signatures.begin(); i != Signatures.end(); ++i)
	{
		if (i->Status == DKIM_SUCCESS)
		{

			if (!i->BodyHashData.empty())
			{
				// check the body hash
				unsigned char md[EVP_MAX_MD_SIZE];
				unsigned len = 0;

				int res = EVP_DigestFinal( &i->m_Bdy_ctx, md, &len);

				if (!res || len != i->BodyHashData.length() || memcmp(i->BodyHashData.data(), md, len) != 0)
				{
					// body hash mismatch

					// if the selector is in testing mode...
					if (i->m_pSelector->Testing)
					{
						i->Status = DKIM_SIGNATURE_BAD_BUT_TESTING;	// todo: make a new error code for this?
						TestingFailures++;
					}
					else
					{
						i->Status = DKIM_BODY_HASH_MISMATCH;
						RealFailures++;
					}

					continue;
				}
			}
			else
			{
				// hash CRLF separating the body from the signature
				i->Hash( "\r\n", 2 );
			}


			// check the header hash
			string sSignedSig = i->Header;
			string sSigValue = sSignedSig.substr( sSignedSig.find(':')+1 );

			static const char *tags[] = {"b",NULL};
			char *values[sizeof(tags)/sizeof(tags[0])] = {NULL};

			char *pSigValue = (char *) sSigValue.c_str();
			if (ParseTagValueList(pSigValue, tags, values) && values[0] != NULL)
			{
				sSignedSig.erase( 15+values[0]-pSigValue, strlen(values[0]) );
			}

			if ( i->HeaderCanonicalization == DKIM_CANON_RELAXED )
			{
				sSignedSig = RelaxHeader( sSignedSig );
			}
			else if ( i->HeaderCanonicalization == DKIM_CANON_NOWSP )
			{
				RemoveSWSP( sSignedSig );
				// convert "DKIM-Signature" to lower case
				sSignedSig.replace( 0, 14, "dkim-signature", 14 );
			}

			i->Hash( sSignedSig.c_str(), sSignedSig.length() );

			assert( i->m_pSelector != NULL );

			int res = EVP_VerifyFinal( &i->m_Hdr_ctx, (unsigned char *) i->SignatureData.data(), i->SignatureData.length(), i->m_pSelector->PublicKey);

			if (res == 1)
			{
				if (i->UnverifiedBodyCount == 0)
					i->Status = DKIM_SUCCESS;
				else
					i->Status = DKIM_SUCCESS_BUT_EXTRA;
				SuccessCount++;
				SuccessfulDomains.push_back( i->Domain );
			}
			else
			{
				// if the selector is in testing mode...
				if (i->m_pSelector->Testing)
				{
					i->Status = DKIM_SIGNATURE_BAD_BUT_TESTING;
					TestingFailures++;
				}
				else
				{
					i->Status = DKIM_SIGNATURE_BAD;
					RealFailures++;
				}
			}
		}
		else if (i->Status == DKIM_SELECTOR_GRANULARITY_MISMATCH || i->Status == DKIM_SELECTOR_ALGORITHM_MISMATCH || i->Status == DKIM_SELECTOR_KEY_REVOKED)
		{
			// treat these as failures
			// todo: maybe see if the selector is in testing mode?
			RealFailures++;
		}
	}


	// get the From address's domain if we might need it
	string sFromDomain;
	if (SuccessCount > 0 || m_CheckPractices)
	{
		for (list<string>::iterator i = HeaderList.begin(); i != HeaderList.end(); ++i)
		{
			if (_strnicmp(i->c_str(), "From", 4) == 0)
			{
				// skip over whitespace between the header name and :
				const char *s = i->c_str()+4;
				while (*s == ' ' || *s == '\t')
					s++;
				if (*s == ':')
				{
					vector<string> Addresses;
					if (ParseAddresses(s+1, Addresses))
					{
						unsigned atpos = Addresses[0].find('@');
						sFromDomain = Addresses[0].substr(atpos+1);
						break;
					}
				}
			}
		}
	}

	// if a signature from the From domain verified successfully, return success now
	// without checking the author domain signing practices
	if (SuccessCount > 0 && !sFromDomain.empty())
	{
		for (list<string>::iterator i = SuccessfulDomains.begin(); i != SuccessfulDomains.end(); ++i)
		{
			// see if the successful domain is the same as or a parent of the From domain
			if (i->length() > sFromDomain.length())
				continue;
			if (_stricmp(i->c_str(), sFromDomain.c_str()+sFromDomain.length()-i->length()) != 0)
				continue;
			if (i->length() == sFromDomain.length() || sFromDomain.c_str()[sFromDomain.length()-i->length()-1] == '.')
			{
				return SuccessCount == Signatures.size() ? DKIM_SUCCESS : DKIM_PARTIAL_SUCCESS;
			}
		}
	}

	// get the author domain signing practices
	int iPractices = DKIM_ADSP_UNKNOWN;

	if (m_CheckPractices && !sFromDomain.empty())
	{
		int ADSPStatus = GetADSP(sFromDomain, iPractices);
		if (ADSPStatus != DKIM_SUCCESS)
		{
			// could not get practices, leave values at the defaults
		}
	}

	// if there was a successful signature and policy is not discardable, return success
	if (SuccessCount > 0 && (iPractices == DKIM_ADSP_UNKNOWN || iPractices == DKIM_ADSP_ALL))
	{
		return SuccessCount == Signatures.size() ? DKIM_SUCCESS : DKIM_PARTIAL_SUCCESS;
	}

	// if the message should be signed, return fail
	if (iPractices == DKIM_ADSP_ALL || iPractices == DKIM_ADSP_DISCARDABLE)
		return DKIM_FAIL;

	// return neutral for everything else
	return DKIM_NEUTRAL;
}

////////////////////////////////////////////////////////////////////////////////
// 
// Hash - update the hash
//
////////////////////////////////////////////////////////////////////////////////
void SignatureInfo::Hash( const char* szBuffer, unsigned nBufLength, bool IsBody )
{
#if 0
	/** START DEBUG CODE **/
	if( nBufLength == 2 && szBuffer[0] == '\r' && szBuffer[1] == '\n' )
	{
		printf( "[CRLF]\n" );
	}
	else
	{
		char* szDbg = new char[nBufLength+1];
		strncpy( szDbg, szBuffer, nBufLength );
		szDbg[nBufLength] = '\0';
		printf( "[%s]\n", szDbg );
	}
	/** END DEBUG CODE **/
#endif

	if (IsBody && BodyLength != -1)
	{
		VerifiedBodyCount += nBufLength;
		if (VerifiedBodyCount > BodyLength)
		{
			nBufLength = BodyLength - (VerifiedBodyCount - nBufLength);
			UnverifiedBodyCount += VerifiedBodyCount - BodyLength;
			VerifiedBodyCount = BodyLength;
			if (nBufLength == 0)
				return;
		}
	}

	if (IsBody && !BodyHashData.empty())
	{
		EVP_DigestUpdate( &m_Bdy_ctx, szBuffer, nBufLength );
	}
	else
	{
		EVP_VerifyUpdate( &m_Hdr_ctx, szBuffer, nBufLength );
	}

	if (m_SaveCanonicalizedData)
	{
		CanonicalizedData.append( szBuffer, nBufLength );
	}
}


////////////////////////////////////////////////////////////////////////////////
// 
// ProcessHeaders - Look for DKIM-Signatures and start processing them
//
////////////////////////////////////////////////////////////////////////////////
int CDKIMVerify::ProcessHeaders(void)
{
	// look for DKIM-Signature header(s)
	for( list<string>::iterator i = HeaderList.begin(); i != HeaderList.end(); ++i )
	{
		if( _strnicmp(i->c_str(), "DKIM-Signature", 14 ) == 0 )
		{
			// skip over whitespace between the header name and :
			const char *s = i->c_str()+14;
			while (*s == ' ' || *s == '\t')
				s++;
			if (*s == ':')
			{
				// found
				SignatureInfo sig(m_SaveCanonicalizedData);
				sig.Status = ParseDKIMSignature( *i, sig );
				Signatures.push_back( sig );

				if (Signatures.size() >= MAX_SIGNATURES)
					break;
			}
		}
	}

	if ( Signatures.empty() )
		return DKIM_NO_SIGNATURES;

	bool ValidSigFound = false;

	for ( list<SignatureInfo>::iterator s = Signatures.begin(); s != Signatures.end(); ++s )
	{
		SignatureInfo &sig = *s;

		if ( sig.Status != DKIM_SUCCESS)
			continue;

		SelectorInfo &sel = GetSelector(sig.Selector, sig.Domain);
		sig.m_pSelector = &sel;

		if (sel.Status != DKIM_SUCCESS)
		{
			sig.Status = sel.Status;
		}
		else
		{
			// check the granularity
			if (!WildcardMatch(sel.Granularity.c_str(), sig.IdentityLocalPart.c_str()))
				sig.Status = DKIM_SELECTOR_GRANULARITY_MISMATCH;		// this error causes the signature to fail

			// check the hash algorithm
			if ( (sig.m_nHash == DKIM_HASH_SHA1 && !sel.AllowSHA1) || (sig.m_nHash == DKIM_HASH_SHA256 && !sel.AllowSHA256) )
				sig.Status = DKIM_SELECTOR_ALGORITHM_MISMATCH;			// causes signature to fail

			// check for same domain
			if (sel.SameDomain && _stricmp(sig.Domain.c_str(), sig.IdentityDomain.c_str()) != 0)
				sig.Status = DKIM_BAD_SYNTAX;
		}

		if (sig.Status != DKIM_SUCCESS)
			continue;

		// initialize the hashes
		if (sig.m_nHash == DKIM_HASH_SHA256)
		{
			EVP_VerifyInit( &sig.m_Hdr_ctx, EVP_sha256() );
			EVP_DigestInit( &sig.m_Bdy_ctx, EVP_sha256() );
		}
		else
		{
			EVP_VerifyInit( &sig.m_Hdr_ctx, EVP_sha1() );
			EVP_DigestInit( &sig.m_Bdy_ctx, EVP_sha1() );
		}

		// compute the hash of the header
		vector<list<string>::reverse_iterator> used;

		for (vector<string>::iterator x = sig.SignedHeaders.begin(); x != sig.SignedHeaders.end(); ++x)
		{
			list<string>::reverse_iterator i;
			for( i = HeaderList.rbegin(); i != HeaderList.rend(); ++i )
			{
				if (_strnicmp(i->c_str(), x->c_str(), x->length()) == 0)
				{
					// skip over whitespace between the header name and :
					const char *s = i->c_str()+x->length();
					while (*s == ' ' || *s == '\t')
						s++;
					if (*s == ':' && find(used.begin(), used.end(), i) == used.end())
						break;
				}
			}

			if (i != HeaderList.rend())
			{
				used.push_back(i);

				// hash this header
				if (sig.HeaderCanonicalization == DKIM_CANON_SIMPLE)
				{
					sig.Hash( i->c_str(), i->length() );
				}
				else if (sig.HeaderCanonicalization == DKIM_CANON_RELAXED)
				{
					string sTemp = RelaxHeader( *i );
					sig.Hash( sTemp.c_str(), sTemp.length() );
				}
				else if (sig.HeaderCanonicalization == DKIM_CANON_NOWSP)
				{
					string sTemp = *i;
					RemoveSWSP( sTemp );

					// convert characters before ':' to lower case
					for( char* s = (char*)sTemp.c_str(); *s != '\0' && *s != ':'; s++ )
					{
						if( *s >= 'A' && *s <= 'Z' )
							*s += 'a'-'A';
					}

					sig.Hash( sTemp.c_str(), sTemp.length() );
				}
				sig.Hash( "\r\n", 2 );
			}
		}

		if (sig.BodyHashData.empty())
		{
			// hash CRLF separating headers from body
			sig.Hash( "\r\n", 2 );
		}

		if (!m_AllowUnsignedFromHeaders)
		{
			// make sure the message has no unsigned From headers
			list<string>::reverse_iterator i;
			for( i = HeaderList.rbegin(); i != HeaderList.rend(); ++i )
			{
				if( _strnicmp(i->c_str(), "From", 4 ) == 0 )
				{
					// skip over whitespace between the header name and :
					const char *s = i->c_str()+4;
					while (*s == ' ' || *s == '\t')
						s++;
					if (*s == ':')
					{
						if (find(used.begin(), used.end(), i) == used.end())
						{
							// this From header was not signed
							break;
						}
					}
				}
			}

			if (i != HeaderList.rend())
			{
				// treat signature as invalid
				sig.Status = DKIM_UNSIGNED_FROM;
				continue;
			}
		}

		ValidSigFound = true;
	}

	if ( !ValidSigFound )
		return DKIM_NO_VALID_SIGNATURES;

	return DKIM_SUCCESS;
}


////////////////////////////////////////////////////////////////////////////////
// 
// Strictly parse an unsigned integer.  Don't allow spaces, negative sign,
// 0x prefix, etc.  Values greater than 2^32-1 are capped at 2^32-1
//
////////////////////////////////////////////////////////////////////////////////
bool ParseUnsigned(const char *s, unsigned *result)
{
	unsigned temp=0, last=0;
	bool overflowed = false;

	do {
		if (*s < '0' || *s > '9')
			return false;				// returns false for an initial '\0'

		temp = temp * 10 + (*s - '0');
		if (temp < last)
			overflowed = true;
		last = temp;

		s++;
	} while (*s != '\0');

	*result = overflowed ? -1 : temp;
	return true;
}


////////////////////////////////////////////////////////////////////////////////
// 
// ParseDKIMSignature - Parse a DKIM-Signature header field
//
////////////////////////////////////////////////////////////////////////////////
int CDKIMVerify::ParseDKIMSignature( const string& sHeader, SignatureInfo &sig )
{
	// save header for later
	sig.Header = sHeader;

	string sValue = sHeader.substr( sHeader.find(':')+1 );

	static const char *tags[] = {"v","a","b","d","h","s","c","i","l","q","t","x","bh",NULL};
	char *values[sizeof(tags)/sizeof(tags[0])] = {NULL};

	if (!ParseTagValueList( (char*) sValue.c_str(), tags, values))
		return DKIM_BAD_SYNTAX;

	// check signature version
	if (values[0] != NULL)
	{
		if (strcmp(values[0], "1") == 0 || strcmp(values[0], "0.5") == 0 || strcmp(values[0], "0.4") == 0 || strcmp(values[0], "0.3") == 0 || strcmp(values[0], "0.2") == 0)
		{
			sig.Version = DKIM_SIG_VERSION_02_PLUS;
		}
		else
		{
			// unknown version
			return DKIM_STAT_INCOMPAT;
		}
	}
	else
	{
		// Note:  DKIM Interop 1 pointed out that v= is now required, but we do
		// not enforce that in order to verify signatures made by older drafts.

		// prior to 0.2, there MUST NOT have been a v=
		// (optionally) support these signatures, for backwards compatibility
		if (true)
		{
			sig.Version = DKIM_SIG_VERSION_PRE_02;
		}
		else
		{
			return DKIM_BAD_SYNTAX;
		}
	}

	// signature MUST have a=, b=, d=, h=, s=
	if (values[1] == NULL || values[2] == NULL || values[3] == NULL || values[4] == NULL || values[5] == NULL)
		return DKIM_BAD_SYNTAX;

	// algorithm can be "rsa-sha1" or "rsa-sha256"
	if (strcmp(values[1], "rsa-sha1") == 0) 
	{
		sig.m_nHash = DKIM_HASH_SHA1;
	}
	else if (strcmp(values[1], "rsa-sha256") == 0)
	{
		sig.m_nHash = DKIM_HASH_SHA256;
	}
	else
	{
		return DKIM_BAD_SYNTAX;		// todo: maybe create a new error code for unknown algorithm
	}

	// make sure the signature data is not empty
	unsigned SigDataLen = DecodeBase64(values[2]);
	if (SigDataLen == 0)
		return DKIM_BAD_SYNTAX;
	sig.SignatureData.assign(values[2], SigDataLen);

	// check for body hash
	if (values[12] == NULL)
	{
		// use the old single hash way for backwards compatibility
		if (sig.Version != DKIM_SIG_VERSION_PRE_02)
			return DKIM_BAD_SYNTAX;
	}
	else
	{
		unsigned BodyHashLen = DecodeBase64(values[12]);
		if (BodyHashLen == 0)
			return DKIM_BAD_SYNTAX;
		sig.BodyHashData.assign(values[12], BodyHashLen);
	}

	// domain must not be empty
	if (*values[3] == '\0')
		return DKIM_BAD_SYNTAX;
	sig.Domain = values[3];

	// signed headers must not be empty (more verification is done later)
	if (*values[4] == '\0')
		return DKIM_BAD_SYNTAX;

	// selector must not be empty
	if (*values[5] == '\0')
		return DKIM_BAD_SYNTAX;
	sig.Selector = values[5];

	// canonicalization
	if (values[6] == NULL)
	{
		sig.HeaderCanonicalization = sig.BodyCanonicalization = DKIM_CANON_SIMPLE;
	}
	else if (sig.Version == DKIM_SIG_VERSION_PRE_02 && strcmp(values[6], "nowsp") == 0)
	{
		// for backwards compatibility
		sig.HeaderCanonicalization = sig.BodyCanonicalization = DKIM_CANON_NOWSP;
	}
	else
	{
		char *slash = strchr(values[6], '/');
		if (slash != NULL)
			*slash = '\0';

		if (strcmp(values[6], "simple") == 0)
			sig.HeaderCanonicalization = DKIM_CANON_SIMPLE;
		else if (strcmp(values[6], "relaxed") == 0)
			sig.HeaderCanonicalization = DKIM_CANON_RELAXED;
		else
			return DKIM_BAD_SYNTAX;

		if (slash == NULL || strcmp(slash+1, "simple") == 0)
			sig.BodyCanonicalization = DKIM_CANON_SIMPLE;
		else if (strcmp(slash+1, "relaxed") == 0)
			sig.BodyCanonicalization = DKIM_CANON_RELAXED;
		else
			return DKIM_BAD_SYNTAX;
	}

	// identity
	if (values[7] == NULL)
	{
		sig.IdentityLocalPart.erase();
		sig.IdentityDomain = sig.Domain;
	}
	else
	{
		// quoted-printable decode the value
		DecodeQuotedPrintable(values[7]);

		// must have a '@' separating the local part from the domain
		char *at = strchr(values[7], '@');
		if (at == NULL)
			return DKIM_BAD_SYNTAX;
		*at = '\0';

		char *ilocalpart = values[7];
		char *idomain = at+1;

		// i= domain must be the same as or a subdomain of the d= domain
		int idomainlen = strlen(idomain);
		int ddomainlen = strlen(values[3]);

		// todo: maybe create a new error code for invalid identity domain
		if (idomainlen < ddomainlen)
			return DKIM_BAD_SYNTAX;
		if (_stricmp(idomain+idomainlen-ddomainlen, values[3]) != 0)
			return DKIM_BAD_SYNTAX;
		if (idomainlen > ddomainlen && idomain[idomainlen-ddomainlen-1] != '.')
			return DKIM_BAD_SYNTAX;

		sig.IdentityLocalPart = ilocalpart;
		sig.IdentityDomain = idomain;
	}

	// body count
	if (values[8] == NULL || !m_HonorBodyLengthTag)
	{
		sig.BodyLength = -1;
	}
	else
	{
		if (!ParseUnsigned(values[8], &sig.BodyLength))
			return DKIM_BAD_SYNTAX;
	}

	// query methods
	if (values[9] != NULL)
	{
		// make sure "dns" is in the list
		bool HasDNS = false;
		char *s = strtok(values[9], ":");
		while (s != NULL)
		{
			if (strncmp(s, "dns", 3) == 0 && (s[3] == '\0' || s[3] == '/'))
			{
				HasDNS = true;
				break;
			}
			s = strtok(NULL, ": \t");
		}
		if (!HasDNS)
			return DKIM_BAD_SYNTAX;		// todo: maybe create a new error code for unknown query method
	}

	// signature time
	unsigned SignedTime = -1;
	if (values[10] != NULL)
	{
		if (!ParseUnsigned(values[10], &SignedTime))
			return DKIM_BAD_SYNTAX;
	}

	// expiration time
	if (values[11] == NULL)
	{
		sig.ExpireTime = -1;
	}
	else
	{
		if (!ParseUnsigned(values[11], &sig.ExpireTime))
			return DKIM_BAD_SYNTAX;

		if (sig.ExpireTime != -1)
		{
			// the value of x= MUST be greater than the value of t= if both are present
			if (SignedTime != -1 && sig.ExpireTime <= SignedTime)
				return DKIM_BAD_SYNTAX;

			// todo: if possible, use the received date/time instead of the current time
			unsigned curtime = time(NULL);
			if (curtime > sig.ExpireTime)
				return DKIM_SIGNATURE_EXPIRED;
		}
	}

	// parse the signed headers list
	bool HasFrom = false, HasSubject = false;
	RemoveSWSP(values[4]);			// header names shouldn't have spaces in them so this should be ok...
	char *s = strtok(values[4], ":");
	while (s != NULL)
	{
		if (_stricmp(s, "From") == 0)
			HasFrom = true;
		else if (_stricmp(s, "Subject") == 0)
			HasSubject = true;

		sig.SignedHeaders.push_back(s);

		s = strtok(NULL, ":");
	}

	if (!HasFrom)
		return DKIM_BAD_SYNTAX;		// todo: maybe create a new error code for h= missing From
	if (m_SubjectIsRequired && !HasSubject)
		return DKIM_BAD_SYNTAX;		// todo: maybe create a new error code for h= missing Subject

	return DKIM_SUCCESS;
}


////////////////////////////////////////////////////////////////////////////////
// 
// ProcessBody - Process message body data
//
////////////////////////////////////////////////////////////////////////////////
int CDKIMVerify::ProcessBody( char* szBuffer, int nBufLength, bool bEOF )
{
	bool MoreBodyNeeded = false;

	for ( list<SignatureInfo>::iterator i = Signatures.begin(); i != Signatures.end(); ++i )
	{
		if ( i->Status == DKIM_SUCCESS )
		{
			if ( i->BodyCanonicalization == DKIM_CANON_SIMPLE )
			{
				if (nBufLength > 0)
				{
					while (i->EmptyLineCount > 0)
					{
						i->Hash( "\r\n", 2, true );
						i->EmptyLineCount--;
					}
					i->Hash( szBuffer, nBufLength, true );
					i->Hash( "\r\n", 2, true );
				}
				else
				{
					i->EmptyLineCount++;
					if (bEOF)
						i->Hash( "\r\n", 2, true);
				}
			}
			else if ( i->BodyCanonicalization == DKIM_CANON_RELAXED )
			{
				CompressSWSP( szBuffer, nBufLength );
				if (nBufLength > 0)
				{
					while (i->EmptyLineCount > 0)
					{
						i->Hash( "\r\n", 2, true );
						i->EmptyLineCount--;
					}
					i->Hash( szBuffer, nBufLength, true );
					if ( !bEOF )
						i->Hash( "\r\n", 2, true);
				}
				else
					i->EmptyLineCount++;
			}
			else if ( i->BodyCanonicalization == DKIM_CANON_NOWSP )
			{
				RemoveSWSP( szBuffer, nBufLength );
				i->Hash( szBuffer, nBufLength, true );
			}

			if ( i->UnverifiedBodyCount == 0 )
				MoreBodyNeeded = true;
		}
	}

	if ( !MoreBodyNeeded )
		return DKIM_FINISHED_BODY;

	return DKIM_SUCCESS;
}


SelectorInfo::SelectorInfo(const string &sSelector, const string &sDomain) : Selector(sSelector), Domain(sDomain)
{
	AllowSHA1 = true;
	AllowSHA256 = true;
	PublicKey = NULL;
	Testing = false;
	SameDomain = false;
	Status = DKIM_SUCCESS;
}

SelectorInfo::~SelectorInfo()
{
	if (PublicKey != NULL)
	{
		EVP_PKEY_free(PublicKey);
	}
}

////////////////////////////////////////////////////////////////////////////////
// 
// Parse - Parse a DKIM selector
//
////////////////////////////////////////////////////////////////////////////////
int SelectorInfo::Parse( char* Buffer )
{
	static const char *tags[] = {"v","g","h","k","p","s","t","n",NULL};
	char *values[sizeof(tags)/sizeof(tags[0])] = {NULL};

	if (!ParseTagValueList(Buffer, tags, values))
		return DKIM_SELECTOR_INVALID;

	if (values[0] != NULL)
	{
		// make sure the version is "DKIM1"
		if (strcmp(values[0], "DKIM1") != 0)
			return DKIM_SELECTOR_INVALID;		// todo: maybe create a new error code for unsupported selector version

		// make sure v= is the first tag in the response	// todo: maybe don't enforce this, it seems unnecessary
		for (int j=1; j<sizeof(values)/sizeof(values[0]); j++)
		{
			if (values[j] != NULL && values[j] < values[0])
			{
				return DKIM_SELECTOR_INVALID;
			}
		}
	}

	// selector MUST have p= tag
	if (values[4] == NULL)
		return DKIM_SELECTOR_INVALID;

	// granularity
	if (values[1] == NULL)
		Granularity = "*";
	else
		Granularity = values[1];

	// hash algorithm
	if (values[2] == NULL)
	{
		AllowSHA1 = true;
		AllowSHA256 = true;
	}
	else
	{
		// MUST include "sha1" or "sha256"
		char *s = strtok(values[2], ":");
		while (s != NULL)
		{
			if (strcmp(s, "sha1") == 0)
				AllowSHA1 = true;
			else if (strcmp(s, "sha256") == 0)
				AllowSHA256 = true;
			s = strtok(NULL, ":");
		}
		if ( !(AllowSHA1 || AllowSHA256) )
			return DKIM_SELECTOR_INVALID;	// todo: maybe create a new error code for unsupported hash algorithm
	}

	// key type
	if (values[3] != NULL)
	{
		// key type MUST be "rsa"
		if (strcmp(values[3], "rsa") != 0)
			return DKIM_SELECTOR_INVALID;
	}

	// service type
	if (values[5] != NULL)
	{
		// make sure "*" or "email" is in the list
		bool ServiceTypeMatch = false;
		char *s = strtok(values[5], ":");
		while (s != NULL)
		{
			if (strcmp(s, "*") == 0 || strcmp(s, "email") == 0)
			{
				ServiceTypeMatch = true;
				break;
			}
			s = strtok(NULL, ":");
		}
		if (!ServiceTypeMatch)
			return DKIM_SELECTOR_INVALID;
	}

	// flags
	if (values[6] != NULL)
	{
		char *s = strtok(values[6], ":");
		while (s != NULL)
		{
			if (strcmp(s, "y") == 0)
			{
				Testing = true;
			}
			else if (strcmp(s, "s") == 0)
			{
				SameDomain = true;
			}
			s = strtok(NULL, ":");
		}
	}

	// public key data
	unsigned PublicKeyLen = DecodeBase64(values[4]);

	if (PublicKeyLen == 0)
	{
		return DKIM_SELECTOR_KEY_REVOKED;	// this error causes the signature to fail
	}
	else
	{
		const unsigned char *PublicKeyData = (unsigned char *)values[4];
		EVP_PKEY *pkey = d2i_PUBKEY(NULL, &PublicKeyData, PublicKeyLen);

		if (pkey == NULL)
			return DKIM_SELECTOR_PUBLIC_KEY_INVALID;

		// make sure public key is the correct type (we only support rsa)
		if (pkey->type == EVP_PKEY_RSA || pkey->type == EVP_PKEY_RSA2)
		{
			PublicKey = pkey;
		}
		else
		{
			EVP_PKEY_free(pkey);
			return DKIM_SELECTOR_PUBLIC_KEY_INVALID;
		}
	}

	return DKIM_SUCCESS;
}


////////////////////////////////////////////////////////////////////////////////
// 
// GetSelector - Get a DKIM selector for a domain
//
////////////////////////////////////////////////////////////////////////////////
SelectorInfo &CDKIMVerify::GetSelector( const string &sSelector, const string &sDomain )
{
	// see if we already have this selector
	for ( list<SelectorInfo>::iterator i = Selectors.begin(); i != Selectors.end(); ++i )
	{
		if ( _stricmp(i->Selector.c_str(), sSelector.c_str()) == 0 && _stricmp(i->Domain.c_str(), sDomain.c_str()) == 0)
		{
			return *i;
		}
	}

	Selectors.push_back( SelectorInfo(sSelector, sDomain) );
	SelectorInfo &sel = Selectors.back();

	string sFQDN = sSelector;
	sFQDN += "._domainkey.";
	sFQDN += sDomain;

	char Buffer[1024];
	int BufLen = 1024;

	int DNSResult;

	if ( m_pfnSelectorCallback )
		DNSResult = m_pfnSelectorCallback( sFQDN.c_str(), Buffer, BufLen );
	else
		DNSResult = DNSGetTXT( sFQDN.c_str(), Buffer, BufLen );

	switch (DNSResult)
	{
	case DNSRESP_SUCCESS:
		sel.Status = sel.Parse( Buffer );
		break;

	case DNSRESP_TEMP_FAIL:
		sel.Status = DKIM_SELECTOR_DNS_TEMP_FAILURE;
		break;

	case DNSRESP_PERM_FAIL:
	default:
		sel.Status = DKIM_SELECTOR_DNS_PERM_FAILURE;
		break;

	case DNSRESP_DOMAIN_NAME_TOO_LONG:
		sel.Status = DKIM_SELECTOR_DOMAIN_NAME_TOO_LONG;
		break;
	}

	return sel;
}


////////////////////////////////////////////////////////////////////////////////
// 
// GetADSP - Get DKIM Author Domain Signing Practices for a domain
//
////////////////////////////////////////////////////////////////////////////////
int CDKIMVerify::GetADSP( const string &sDomain, int &iADSP )
{
	string sFQDN = "_adsp._domainkey.";
	sFQDN += sDomain;

	char Buffer[1024];
	int BufLen = 1024;

	int DNSResult;

	if ( m_pfnPracticesCallback )
		DNSResult = m_pfnPracticesCallback( sFQDN.c_str(), Buffer, BufLen );
	else
	{
		DNSResult = DNSGetTXT( sFQDN.c_str(), Buffer, BufLen );

		if (DNSResult != DNSRESP_SUCCESS)
		{
			int DomainDNSResult = DNSGetTXT( sDomain.c_str(), Buffer, BufLen );
			if (DomainDNSResult == DNSRESP_NXDOMAIN)
			{
				return DKIM_POLICY_DNS_PERM_FAILURE;	// TODO: new error indicating domain is out of scope?
			}
		}
	}

	switch (DNSResult)
	{
	case DNSRESP_SUCCESS:
		{
			Practices = Buffer;

			static const char *tags[] = {"dkim",NULL};
			char *values[sizeof(tags)/sizeof(tags[0])] = {NULL};

			if (!ParseTagValueList(Buffer, tags, values))
				return DKIM_POLICY_INVALID;

			// practices
			iADSP = DKIM_ADSP_UNKNOWN;
			if (values[0] != NULL)
			{
				if (strcmp(values[0], "all") == 0)
					iADSP = DKIM_ADSP_ALL;
				else if (strcmp(values[0], "discardable") == 0)
					iADSP = DKIM_ADSP_DISCARDABLE;
			}
		}
		return DKIM_SUCCESS;

	case DNSRESP_TEMP_FAIL:
		return DKIM_POLICY_DNS_TEMP_FAILURE;

	case DNSRESP_PERM_FAIL:
	default:
		return DKIM_POLICY_DNS_PERM_FAILURE;

	case DNSRESP_DOMAIN_NAME_TOO_LONG:
		return DKIM_POLICY_DOMAIN_NAME_TOO_LONG;
	}
}


////////////////////////////////////////////////////////////////////////////////
// 
// GetDetails - Get DKIM verification details (per signature)
//
////////////////////////////////////////////////////////////////////////////////
int CDKIMVerify::GetDetails( int* nSigCount, DKIMVerifyDetails** pDetails )
{
	Details.clear();

	for (list<SignatureInfo>::iterator i = Signatures.begin(); i != Signatures.end(); ++i)
	{
		DKIMVerifyDetails d;
		d.szSignature = (char*)i->Header.c_str();
		d.szSignatureDomain = (char*)i->Domain.c_str();
		d.szIdentityDomain = (char*)i->IdentityDomain.c_str();
		d.szCanonicalizedData = (char*)i->CanonicalizedData.c_str();
		d.nResult = i->Status;
		Details.push_back(d);
	}

	*nSigCount = Details.size();
	*pDetails = (*nSigCount != 0) ? &Details[0] : NULL;

	return DKIM_SUCCESS;
}

