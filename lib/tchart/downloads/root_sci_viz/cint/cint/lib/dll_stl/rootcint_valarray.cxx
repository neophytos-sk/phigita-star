//
// File generated by core/utils/src/rootcint_tmp at Sat Jan 22 22:07:14 2011

// Do NOT change. Changes will be lost next time file is generated
//

#define R__DICTIONARY_FILENAME cintdIcintdIlibdIdll_stldIrootcint_valarray
#include "RConfig.h" //rootcint 4834
#if !defined(R__ACCESS_IN_SYMBOL)
//Break the privacy of classes -- Disabled for the moment
#define private public
#define protected public
#endif

// Since CINT ignores the std namespace, we need to do so in this file.
namespace std {} using namespace std;
#include "rootcint_valarray.h"

#include "TClass.h"
#include "TBuffer.h"
#include "TMemberInspector.h"
#include "TError.h"

#ifndef G__ROOT
#define G__ROOT
#endif

#include "RtypesImp.h"
#include "TIsAProxy.h"

// START OF SHADOWS

namespace ROOT {
   namespace Shadow {
   } // of namespace Shadow
} // of namespace ROOT
// END OF SHADOWS

namespace ROOT {
   void valarraylEintgR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void valarraylEintgR_Dictionary();
   static void *new_valarraylEintgR(void *p = 0);
   static void *newArray_valarraylEintgR(Long_t size, void *p);
   static void delete_valarraylEintgR(void *p);
   static void deleteArray_valarraylEintgR(void *p);
   static void destruct_valarraylEintgR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const ::valarray<int>*)
   {
      ::valarray<int> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(::valarray<int>),0);
      static ::ROOT::TGenericClassInfo 
         instance("valarray<int>", "prec_stl/valarray", 29,
                  typeid(::valarray<int>), DefineBehavior(ptr, ptr),
                  0, &valarraylEintgR_Dictionary, isa_proxy, 0,
                  sizeof(::valarray<int>) );
      instance.SetNew(&new_valarraylEintgR);
      instance.SetNewArray(&newArray_valarraylEintgR);
      instance.SetDelete(&delete_valarraylEintgR);
      instance.SetDeleteArray(&deleteArray_valarraylEintgR);
      instance.SetDestructor(&destruct_valarraylEintgR);
      return &instance;
   }
   TGenericClassInfo *GenerateInitInstance(const ::valarray<int>*)
   {
      return GenerateInitInstanceLocal((::valarray<int>*)0);
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const ::valarray<int>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void valarraylEintgR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const ::valarray<int>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_valarraylEintgR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) ::valarray<int> : new ::valarray<int>;
   }
   static void *newArray_valarraylEintgR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) ::valarray<int>[nElements] : new ::valarray<int>[nElements];
   }
   // Wrapper around operator delete
   static void delete_valarraylEintgR(void *p) {
      delete ((::valarray<int>*)p);
   }
   static void deleteArray_valarraylEintgR(void *p) {
      delete [] ((::valarray<int>*)p);
   }
   static void destruct_valarraylEintgR(void *p) {
      typedef ::valarray<int> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class ::valarray<int>

namespace ROOT {
   void valarraylElonggR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void valarraylElonggR_Dictionary();
   static void *new_valarraylElonggR(void *p = 0);
   static void *newArray_valarraylElonggR(Long_t size, void *p);
   static void delete_valarraylElonggR(void *p);
   static void deleteArray_valarraylElonggR(void *p);
   static void destruct_valarraylElonggR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const ::valarray<long>*)
   {
      ::valarray<long> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(::valarray<long>),0);
      static ::ROOT::TGenericClassInfo 
         instance("valarray<long>", "prec_stl/valarray", 29,
                  typeid(::valarray<long>), DefineBehavior(ptr, ptr),
                  0, &valarraylElonggR_Dictionary, isa_proxy, 0,
                  sizeof(::valarray<long>) );
      instance.SetNew(&new_valarraylElonggR);
      instance.SetNewArray(&newArray_valarraylElonggR);
      instance.SetDelete(&delete_valarraylElonggR);
      instance.SetDeleteArray(&deleteArray_valarraylElonggR);
      instance.SetDestructor(&destruct_valarraylElonggR);
      return &instance;
   }
   TGenericClassInfo *GenerateInitInstance(const ::valarray<long>*)
   {
      return GenerateInitInstanceLocal((::valarray<long>*)0);
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const ::valarray<long>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void valarraylElonggR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const ::valarray<long>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_valarraylElonggR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) ::valarray<long> : new ::valarray<long>;
   }
   static void *newArray_valarraylElonggR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) ::valarray<long>[nElements] : new ::valarray<long>[nElements];
   }
   // Wrapper around operator delete
   static void delete_valarraylElonggR(void *p) {
      delete ((::valarray<long>*)p);
   }
   static void deleteArray_valarraylElonggR(void *p) {
      delete [] ((::valarray<long>*)p);
   }
   static void destruct_valarraylElonggR(void *p) {
      typedef ::valarray<long> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class ::valarray<long>

namespace ROOT {
   void valarraylEdoublegR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void valarraylEdoublegR_Dictionary();
   static void *new_valarraylEdoublegR(void *p = 0);
   static void *newArray_valarraylEdoublegR(Long_t size, void *p);
   static void delete_valarraylEdoublegR(void *p);
   static void deleteArray_valarraylEdoublegR(void *p);
   static void destruct_valarraylEdoublegR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const ::valarray<double>*)
   {
      ::valarray<double> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(::valarray<double>),0);
      static ::ROOT::TGenericClassInfo 
         instance("valarray<double>", "prec_stl/valarray", 29,
                  typeid(::valarray<double>), DefineBehavior(ptr, ptr),
                  0, &valarraylEdoublegR_Dictionary, isa_proxy, 0,
                  sizeof(::valarray<double>) );
      instance.SetNew(&new_valarraylEdoublegR);
      instance.SetNewArray(&newArray_valarraylEdoublegR);
      instance.SetDelete(&delete_valarraylEdoublegR);
      instance.SetDeleteArray(&deleteArray_valarraylEdoublegR);
      instance.SetDestructor(&destruct_valarraylEdoublegR);
      return &instance;
   }
   TGenericClassInfo *GenerateInitInstance(const ::valarray<double>*)
   {
      return GenerateInitInstanceLocal((::valarray<double>*)0);
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const ::valarray<double>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void valarraylEdoublegR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const ::valarray<double>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_valarraylEdoublegR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) ::valarray<double> : new ::valarray<double>;
   }
   static void *newArray_valarraylEdoublegR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) ::valarray<double>[nElements] : new ::valarray<double>[nElements];
   }
   // Wrapper around operator delete
   static void delete_valarraylEdoublegR(void *p) {
      delete ((::valarray<double>*)p);
   }
   static void deleteArray_valarraylEdoublegR(void *p) {
      delete [] ((::valarray<double>*)p);
   }
   static void destruct_valarraylEdoublegR(void *p) {
      typedef ::valarray<double> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class ::valarray<double>

/********************************************************
* cint/cint/lib/dll_stl/rootcint_valarray.cxx
* CAUTION: DON'T CHANGE THIS FILE. THIS FILE IS AUTOMATICALLY GENERATED
*          FROM HEADER FILES LISTED IN G__setup_cpp_environmentXXX().
*          CHANGE THOSE HEADER FILES AND REGENERATE THIS FILE.
********************************************************/

#ifdef G__MEMTEST
#undef malloc
#undef free
#endif

#if defined(__GNUC__) && __GNUC__ >= 4 && ((__GNUC_MINOR__ == 2 && __GNUC_PATCHLEVEL__ >= 1) || (__GNUC_MINOR__ >= 3))
#pragma GCC diagnostic ignored "-Wstrict-aliasing"
#endif

extern "C" void G__cpp_reset_tagtablerootcint_valarray();

extern "C" void G__set_cpp_environmentrootcint_valarray() {
  G__add_compiledheader("TObject.h");
  G__add_compiledheader("TMemberInspector.h");
  G__add_compiledheader("valarray");
  G__cpp_reset_tagtablerootcint_valarray();
}
#include <new>
extern "C" int G__cpp_dllrevrootcint_valarray() { return(30051515); }

/*********************************************************
* Member function Interface Method
*********************************************************/

/* Setting up global function */

/*********************************************************
* Member function Stub
*********************************************************/

/*********************************************************
* Global function Stub
*********************************************************/

/*********************************************************
* Get size of pointer to member function
*********************************************************/
class G__Sizep2memfuncrootcint_valarray {
 public:
  G__Sizep2memfuncrootcint_valarray(): p(&G__Sizep2memfuncrootcint_valarray::sizep2memfunc) {}
    size_t sizep2memfunc() { return(sizeof(p)); }
  private:
    size_t (G__Sizep2memfuncrootcint_valarray::*p)();
};

size_t G__get_sizep2memfuncrootcint_valarray()
{
  G__Sizep2memfuncrootcint_valarray a;
  G__setsizep2memfunc((int)a.sizep2memfunc());
  return((size_t)a.sizep2memfunc());
}


/*********************************************************
* virtual base class offset calculation interface
*********************************************************/

   /* Setting up class inheritance */

/*********************************************************
* Inheritance information setup/
*********************************************************/
extern "C" void G__cpp_setup_inheritancerootcint_valarray() {

   /* Setting up class inheritance */
}

/*********************************************************
* typedef information setup/
*********************************************************/
extern "C" void G__cpp_setup_typetablerootcint_valarray() {

   /* Setting up typedef entry */
   G__search_typename2("vector<ROOT::TSchemaHelper>",117,G__get_linked_tagnum(&G__rootcint_valarrayLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR),0,-1);
   G__setnewtype(-1,NULL,0);
   G__search_typename2("reverse_iterator<const_iterator>",117,G__get_linked_tagnum(&G__rootcint_valarrayLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR),0,G__get_linked_tagnum(&G__rootcint_valarrayLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR));
   G__setnewtype(-1,NULL,0);
   G__search_typename2("reverse_iterator<iterator>",117,G__get_linked_tagnum(&G__rootcint_valarrayLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR),0,G__get_linked_tagnum(&G__rootcint_valarrayLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR));
   G__setnewtype(-1,NULL,0);
   G__search_typename2("vector<TVirtualArray*>",117,G__get_linked_tagnum(&G__rootcint_valarrayLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR),0,-1);
   G__setnewtype(-1,NULL,0);
   G__search_typename2("reverse_iterator<const_iterator>",117,G__get_linked_tagnum(&G__rootcint_valarrayLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR),0,G__get_linked_tagnum(&G__rootcint_valarrayLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR));
   G__setnewtype(-1,NULL,0);
   G__search_typename2("reverse_iterator<iterator>",117,G__get_linked_tagnum(&G__rootcint_valarrayLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR),0,G__get_linked_tagnum(&G__rootcint_valarrayLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR));
   G__setnewtype(-1,NULL,0);
}

/*********************************************************
* Data Member information setup/
*********************************************************/

   /* Setting up class,struct,union tag member variable */
extern "C" void G__cpp_setup_memvarrootcint_valarray() {
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
* Member function information setup for each class
*********************************************************/

/*********************************************************
* Member function information setup
*********************************************************/
extern "C" void G__cpp_setup_memfuncrootcint_valarray() {
}

/*********************************************************
* Global variable information setup for each class
*********************************************************/
static void G__cpp_setup_global0() {

   /* Setting up global variables */
   G__resetplocal();

}

static void G__cpp_setup_global1() {

   G__resetglobalenv();
}
extern "C" void G__cpp_setup_globalrootcint_valarray() {
  G__cpp_setup_global0();
  G__cpp_setup_global1();
}

/*********************************************************
* Global function information setup for each class
*********************************************************/
static void G__cpp_setup_func0() {
   G__lastifuncposition();

}

static void G__cpp_setup_func1() {
}

static void G__cpp_setup_func2() {

   G__resetifuncposition();
}

extern "C" void G__cpp_setup_funcrootcint_valarray() {
  G__cpp_setup_func0();
  G__cpp_setup_func1();
  G__cpp_setup_func2();
}

/*********************************************************
* Class,struct,union,enum tag information setup
*********************************************************/
/* Setup class/struct taginfo */
G__linked_taginfo G__rootcint_valarrayLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR = { "vector<ROOT::TSchemaHelper,allocator<ROOT::TSchemaHelper> >" , 99 , -1 };
G__linked_taginfo G__rootcint_valarrayLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR = { "reverse_iterator<vector<ROOT::TSchemaHelper,allocator<ROOT::TSchemaHelper> >::iterator>" , 99 , -1 };
G__linked_taginfo G__rootcint_valarrayLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR = { "vector<TVirtualArray*,allocator<TVirtualArray*> >" , 99 , -1 };
G__linked_taginfo G__rootcint_valarrayLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR = { "reverse_iterator<vector<TVirtualArray*,allocator<TVirtualArray*> >::iterator>" , 99 , -1 };

/* Reset class/struct taginfo */
extern "C" void G__cpp_reset_tagtablerootcint_valarray() {
  G__rootcint_valarrayLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR.tagnum = -1 ;
  G__rootcint_valarrayLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR.tagnum = -1 ;
  G__rootcint_valarrayLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR.tagnum = -1 ;
  G__rootcint_valarrayLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR.tagnum = -1 ;
}


extern "C" void G__cpp_setup_tagtablerootcint_valarray() {

   /* Setting up class,struct,union tag entry */
   G__get_linked_tagnum_fwd(&G__rootcint_valarrayLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR);
   G__get_linked_tagnum_fwd(&G__rootcint_valarrayLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR);
   G__get_linked_tagnum_fwd(&G__rootcint_valarrayLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR);
   G__get_linked_tagnum_fwd(&G__rootcint_valarrayLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR);
}
extern "C" void G__cpp_setuprootcint_valarray(void) {
  G__check_setup_version(30051515,"G__cpp_setuprootcint_valarray()");
  G__set_cpp_environmentrootcint_valarray();
  G__cpp_setup_tagtablerootcint_valarray();

  G__cpp_setup_inheritancerootcint_valarray();

  G__cpp_setup_typetablerootcint_valarray();

  G__cpp_setup_memvarrootcint_valarray();

  G__cpp_setup_memfuncrootcint_valarray();
  G__cpp_setup_globalrootcint_valarray();
  G__cpp_setup_funcrootcint_valarray();

   if(0==G__getsizep2memfunc()) G__get_sizep2memfuncrootcint_valarray();
  return;
}
class G__cpp_setup_initrootcint_valarray {
  public:
    G__cpp_setup_initrootcint_valarray() { G__add_setup_func("rootcint_valarray",(G__incsetup)(&G__cpp_setuprootcint_valarray)); G__call_setup_funcs(); }
   ~G__cpp_setup_initrootcint_valarray() { G__remove_setup_func("rootcint_valarray"); }
};
G__cpp_setup_initrootcint_valarray G__cpp_setup_initializerrootcint_valarray;

