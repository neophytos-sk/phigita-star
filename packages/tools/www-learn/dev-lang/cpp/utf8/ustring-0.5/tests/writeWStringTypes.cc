
#include <iconv.h>
#include <stdio.h>
#include <errno.h>

#ifdef HAVE_STDINT_H
# include <stdint.h>
#endif

int main()
{
  printf("\n#ifndef _WSTRINGTYPES_H_\n#define _WSTRINGTYPES_H_\n");

#ifdef HAVE_STDINT_H
  printf("#include <stdint.h>\n");

# ifdef INTERNAL_ICONV_TYPE_UCS4
  printf("typedef uint32_t WChar;\n");
  printf("#define WCHAR_MAX 0xffffffff\n");
  typedef uint32_t WChar;
# else
  printf("typedef uint16_t WChar;\n");
  printf("#define WCHAR_MAX 0xffff\n");
  typedef uint16_t WChar;
# endif  

#else

# ifdef INTERNAL_ICONV_TYPE_UCS4
#   if SIZEOF_UNSIGNED_SHORT_INT>=4
  printf("typedef unsigned short int WChar;\n");
  printf("#define WCHAR_MAX 0xffffffff\n");
#    define WChar unsigned short int
#   elif SIZEOF_UNSIGNED_LONG_INT>=4
  printf("typedef unsigned long int WChar;\n");
  printf("#define WCHAR_MAX 0xffffffff\n");
#    define WChar unsigned long int
#   else
  printf("#error Both long int and short are < 4 !\n");
#   endif
# else

#   if SIZEOF_UNSIGNED_SHORT_INT>=2
  printf("typedef unsigned short int WChar;\n");
  printf("#define WCHAR_MAX 0xffff\n");
#     define WChar unsigned short int
#   elif SIZEOF_UNSIGNED_LONG_INT>=2
  printf("typedef unsigned long int WChar;\n");
  printf("#define WCHAR_MAX 0xffff\n");
#     define WChar unsigned long int
#   else
  printf("#error Both long int and short are < 4 !\n");
#   endif
# endif
#endif

#ifdef INTERNAL_ICONV_TYPE_UCS4
# define UCS "UCS-4"
#else
# define UCS "UCS-2"
#endif

  iconv_t enc = iconv_open(UCS, "ISO-8859-1");
  if (enc == (iconv_t)-1)
    {
      printf("#error Your local iconv implementation does not handle UCS !");
    }
  else
    {
      const char *bufin = "é";
      const char *bufinptr = &bufin[0];
      WChar bufoutwc[32];
      bufoutwc[0] = 0;
      char **bufout = (char**) &bufoutwc[0];
      WChar* wc = &bufoutwc[0];
      size_t lengthin = 1;
      size_t lengthout = 32;

      size_t res = iconv(enc, &bufinptr, &lengthin, (char**)&bufout, &lengthout);
      
      switch (errno)
	{
	case E2BIG:
	  printf("E2BIG !\n");
	  break;
	case EILSEQ:
	  printf("EILSEQ !\n");
	  break;
	case EINVAL:
	  printf("EINVAL !\n");
	  break;
	case EBADF:
	  printf("EBADF !\n");
	  break;
	}

      //      printf("wc = %lx res=%d lenghout=%d\n", *wc, res,lengthout);

#ifdef INTERNAL_ICONV_TYPE_UCS4
      if (*wc == 0xe9)
	{
	  printf("#define CONVERTUNICODEINTERNAL(x) x\n");
	}
      else if (*wc == 0xe9000000)
	{
	  // little-endian
	  printf("#define CONVERTUNICODEINTERNAL(x) (((x>>24)&0xff) | ((x>>8)&0xff00) | ((x<<8)&0xff0000) | ((x&0xff)<<24))\n");
	}
#else
      if (*wc == 0xe9)
	{
	  printf("#define CONVERTUNICODEINTERNAL(x) x\n");
	}
      else if (*wc == 0xe900)
	{
	  // little-endian
	  printf("#define CONVERTUNICODEINTERNAL(x) (((x>>8)&0xff) | ((x<<8)&0xff00))\n");
	}
#endif
      
      printf("#define INTERNALTOHOST(x) CONVERTUNICODEINTERNAL(x)\n");
      printf("#define HOSTTOINTERNAL(x) CONVERTUNICODEINTERNAL(x)\n");

      iconv_close(enc); 
    }


#ifdef INTERNAL_ICONV_TYPE_UCS4
  printf("#define WSTRING_INTERNAL_CHARSET \"UCS-4\"\n");
#else
  printf("#define WSTRING_INTERNAL_CHARSET \"UCS-2\"\n");
#endif

  printf("#endif\n");
}

