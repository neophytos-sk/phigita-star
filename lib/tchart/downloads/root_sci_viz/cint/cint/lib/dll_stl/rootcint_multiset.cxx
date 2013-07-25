//
// File generated by core/utils/src/rootcint_tmp at Sat Jan 22 22:07:13 2011

// Do NOT change. Changes will be lost next time file is generated
//

#define R__DICTIONARY_FILENAME cintdIcintdIlibdIdll_stldIrootcint_multiset
#include "RConfig.h" //rootcint 4834
#if !defined(R__ACCESS_IN_SYMBOL)
//Break the privacy of classes -- Disabled for the moment
#define private public
#define protected public
#endif

// Since CINT ignores the std namespace, we need to do so in this file.
namespace std {} using namespace std;
#include "rootcint_multiset.h"

#include "TCollectionProxyInfo.h"
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
   void multisetlEcharmUgR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void multisetlEcharmUgR_Dictionary();
   static void *new_multisetlEcharmUgR(void *p = 0);
   static void *newArray_multisetlEcharmUgR(Long_t size, void *p);
   static void delete_multisetlEcharmUgR(void *p);
   static void deleteArray_multisetlEcharmUgR(void *p);
   static void destruct_multisetlEcharmUgR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const multiset<char*>*)
   {
      multiset<char*> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(multiset<char*>),0);
      static ::ROOT::TGenericClassInfo 
         instance("multiset<char*>", -2, "prec_stl/multiset", 49,
                  typeid(multiset<char*>), DefineBehavior(ptr, ptr),
                  0, &multisetlEcharmUgR_Dictionary, isa_proxy, 0,
                  sizeof(multiset<char*>) );
      instance.SetNew(&new_multisetlEcharmUgR);
      instance.SetNewArray(&newArray_multisetlEcharmUgR);
      instance.SetDelete(&delete_multisetlEcharmUgR);
      instance.SetDeleteArray(&deleteArray_multisetlEcharmUgR);
      instance.SetDestructor(&destruct_multisetlEcharmUgR);
      instance.AdoptCollectionProxyInfo(TCollectionProxyInfo::Generate(TCollectionProxyInfo::Insert< multiset<char*> >()));
      return &instance;
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const multiset<char*>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void multisetlEcharmUgR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const multiset<char*>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_multisetlEcharmUgR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) multiset<char*> : new multiset<char*>;
   }
   static void *newArray_multisetlEcharmUgR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) multiset<char*>[nElements] : new multiset<char*>[nElements];
   }
   // Wrapper around operator delete
   static void delete_multisetlEcharmUgR(void *p) {
      delete ((multiset<char*>*)p);
   }
   static void deleteArray_multisetlEcharmUgR(void *p) {
      delete [] ((multiset<char*>*)p);
   }
   static void destruct_multisetlEcharmUgR(void *p) {
      typedef multiset<char*> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class multiset<char*>

namespace ROOT {
   void multisetlEdoublegR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void multisetlEdoublegR_Dictionary();
   static void *new_multisetlEdoublegR(void *p = 0);
   static void *newArray_multisetlEdoublegR(Long_t size, void *p);
   static void delete_multisetlEdoublegR(void *p);
   static void deleteArray_multisetlEdoublegR(void *p);
   static void destruct_multisetlEdoublegR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const multiset<double>*)
   {
      multiset<double> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(multiset<double>),0);
      static ::ROOT::TGenericClassInfo 
         instance("multiset<double>", -2, "prec_stl/multiset", 49,
                  typeid(multiset<double>), DefineBehavior(ptr, ptr),
                  0, &multisetlEdoublegR_Dictionary, isa_proxy, 0,
                  sizeof(multiset<double>) );
      instance.SetNew(&new_multisetlEdoublegR);
      instance.SetNewArray(&newArray_multisetlEdoublegR);
      instance.SetDelete(&delete_multisetlEdoublegR);
      instance.SetDeleteArray(&deleteArray_multisetlEdoublegR);
      instance.SetDestructor(&destruct_multisetlEdoublegR);
      instance.AdoptCollectionProxyInfo(TCollectionProxyInfo::Generate(TCollectionProxyInfo::Insert< multiset<double> >()));
      return &instance;
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const multiset<double>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void multisetlEdoublegR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const multiset<double>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_multisetlEdoublegR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) multiset<double> : new multiset<double>;
   }
   static void *newArray_multisetlEdoublegR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) multiset<double>[nElements] : new multiset<double>[nElements];
   }
   // Wrapper around operator delete
   static void delete_multisetlEdoublegR(void *p) {
      delete ((multiset<double>*)p);
   }
   static void deleteArray_multisetlEdoublegR(void *p) {
      delete [] ((multiset<double>*)p);
   }
   static void destruct_multisetlEdoublegR(void *p) {
      typedef multiset<double> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class multiset<double>

namespace ROOT {
   void multisetlEfloatgR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void multisetlEfloatgR_Dictionary();
   static void *new_multisetlEfloatgR(void *p = 0);
   static void *newArray_multisetlEfloatgR(Long_t size, void *p);
   static void delete_multisetlEfloatgR(void *p);
   static void deleteArray_multisetlEfloatgR(void *p);
   static void destruct_multisetlEfloatgR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const multiset<float>*)
   {
      multiset<float> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(multiset<float>),0);
      static ::ROOT::TGenericClassInfo 
         instance("multiset<float>", -2, "prec_stl/multiset", 49,
                  typeid(multiset<float>), DefineBehavior(ptr, ptr),
                  0, &multisetlEfloatgR_Dictionary, isa_proxy, 0,
                  sizeof(multiset<float>) );
      instance.SetNew(&new_multisetlEfloatgR);
      instance.SetNewArray(&newArray_multisetlEfloatgR);
      instance.SetDelete(&delete_multisetlEfloatgR);
      instance.SetDeleteArray(&deleteArray_multisetlEfloatgR);
      instance.SetDestructor(&destruct_multisetlEfloatgR);
      instance.AdoptCollectionProxyInfo(TCollectionProxyInfo::Generate(TCollectionProxyInfo::Insert< multiset<float> >()));
      return &instance;
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const multiset<float>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void multisetlEfloatgR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const multiset<float>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_multisetlEfloatgR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) multiset<float> : new multiset<float>;
   }
   static void *newArray_multisetlEfloatgR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) multiset<float>[nElements] : new multiset<float>[nElements];
   }
   // Wrapper around operator delete
   static void delete_multisetlEfloatgR(void *p) {
      delete ((multiset<float>*)p);
   }
   static void deleteArray_multisetlEfloatgR(void *p) {
      delete [] ((multiset<float>*)p);
   }
   static void destruct_multisetlEfloatgR(void *p) {
      typedef multiset<float> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class multiset<float>

namespace ROOT {
   void multisetlEintgR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void multisetlEintgR_Dictionary();
   static void *new_multisetlEintgR(void *p = 0);
   static void *newArray_multisetlEintgR(Long_t size, void *p);
   static void delete_multisetlEintgR(void *p);
   static void deleteArray_multisetlEintgR(void *p);
   static void destruct_multisetlEintgR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const multiset<int>*)
   {
      multiset<int> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(multiset<int>),0);
      static ::ROOT::TGenericClassInfo 
         instance("multiset<int>", -2, "prec_stl/multiset", 49,
                  typeid(multiset<int>), DefineBehavior(ptr, ptr),
                  0, &multisetlEintgR_Dictionary, isa_proxy, 0,
                  sizeof(multiset<int>) );
      instance.SetNew(&new_multisetlEintgR);
      instance.SetNewArray(&newArray_multisetlEintgR);
      instance.SetDelete(&delete_multisetlEintgR);
      instance.SetDeleteArray(&deleteArray_multisetlEintgR);
      instance.SetDestructor(&destruct_multisetlEintgR);
      instance.AdoptCollectionProxyInfo(TCollectionProxyInfo::Generate(TCollectionProxyInfo::Insert< multiset<int> >()));
      return &instance;
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const multiset<int>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void multisetlEintgR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const multiset<int>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_multisetlEintgR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) multiset<int> : new multiset<int>;
   }
   static void *newArray_multisetlEintgR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) multiset<int>[nElements] : new multiset<int>[nElements];
   }
   // Wrapper around operator delete
   static void delete_multisetlEintgR(void *p) {
      delete ((multiset<int>*)p);
   }
   static void deleteArray_multisetlEintgR(void *p) {
      delete [] ((multiset<int>*)p);
   }
   static void destruct_multisetlEintgR(void *p) {
      typedef multiset<int> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class multiset<int>

namespace ROOT {
   void multisetlElonggR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void multisetlElonggR_Dictionary();
   static void *new_multisetlElonggR(void *p = 0);
   static void *newArray_multisetlElonggR(Long_t size, void *p);
   static void delete_multisetlElonggR(void *p);
   static void deleteArray_multisetlElonggR(void *p);
   static void destruct_multisetlElonggR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const multiset<long>*)
   {
      multiset<long> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(multiset<long>),0);
      static ::ROOT::TGenericClassInfo 
         instance("multiset<long>", -2, "prec_stl/multiset", 49,
                  typeid(multiset<long>), DefineBehavior(ptr, ptr),
                  0, &multisetlElonggR_Dictionary, isa_proxy, 0,
                  sizeof(multiset<long>) );
      instance.SetNew(&new_multisetlElonggR);
      instance.SetNewArray(&newArray_multisetlElonggR);
      instance.SetDelete(&delete_multisetlElonggR);
      instance.SetDeleteArray(&deleteArray_multisetlElonggR);
      instance.SetDestructor(&destruct_multisetlElonggR);
      instance.AdoptCollectionProxyInfo(TCollectionProxyInfo::Generate(TCollectionProxyInfo::Insert< multiset<long> >()));
      return &instance;
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const multiset<long>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void multisetlElonggR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const multiset<long>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_multisetlElonggR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) multiset<long> : new multiset<long>;
   }
   static void *newArray_multisetlElonggR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) multiset<long>[nElements] : new multiset<long>[nElements];
   }
   // Wrapper around operator delete
   static void delete_multisetlElonggR(void *p) {
      delete ((multiset<long>*)p);
   }
   static void deleteArray_multisetlElonggR(void *p) {
      delete [] ((multiset<long>*)p);
   }
   static void destruct_multisetlElonggR(void *p) {
      typedef multiset<long> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class multiset<long>

namespace ROOT {
   void multisetlEstringgR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void multisetlEstringgR_Dictionary();
   static void *new_multisetlEstringgR(void *p = 0);
   static void *newArray_multisetlEstringgR(Long_t size, void *p);
   static void delete_multisetlEstringgR(void *p);
   static void deleteArray_multisetlEstringgR(void *p);
   static void destruct_multisetlEstringgR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const multiset<string>*)
   {
      multiset<string> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(multiset<string>),0);
      static ::ROOT::TGenericClassInfo 
         instance("multiset<string>", -2, "prec_stl/multiset", 49,
                  typeid(multiset<string>), DefineBehavior(ptr, ptr),
                  0, &multisetlEstringgR_Dictionary, isa_proxy, 0,
                  sizeof(multiset<string>) );
      instance.SetNew(&new_multisetlEstringgR);
      instance.SetNewArray(&newArray_multisetlEstringgR);
      instance.SetDelete(&delete_multisetlEstringgR);
      instance.SetDeleteArray(&deleteArray_multisetlEstringgR);
      instance.SetDestructor(&destruct_multisetlEstringgR);
      instance.AdoptCollectionProxyInfo(TCollectionProxyInfo::Generate(TCollectionProxyInfo::Insert< multiset<string> >()));
      return &instance;
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const multiset<string>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void multisetlEstringgR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const multiset<string>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_multisetlEstringgR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) multiset<string> : new multiset<string>;
   }
   static void *newArray_multisetlEstringgR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) multiset<string>[nElements] : new multiset<string>[nElements];
   }
   // Wrapper around operator delete
   static void delete_multisetlEstringgR(void *p) {
      delete ((multiset<string>*)p);
   }
   static void deleteArray_multisetlEstringgR(void *p) {
      delete [] ((multiset<string>*)p);
   }
   static void destruct_multisetlEstringgR(void *p) {
      typedef multiset<string> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class multiset<string>

namespace ROOT {
   void multisetlEvoidmUgR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void multisetlEvoidmUgR_Dictionary();
   static void *new_multisetlEvoidmUgR(void *p = 0);
   static void *newArray_multisetlEvoidmUgR(Long_t size, void *p);
   static void delete_multisetlEvoidmUgR(void *p);
   static void deleteArray_multisetlEvoidmUgR(void *p);
   static void destruct_multisetlEvoidmUgR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const multiset<void*>*)
   {
      multiset<void*> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(multiset<void*>),0);
      static ::ROOT::TGenericClassInfo 
         instance("multiset<void*>", -2, "prec_stl/multiset", 49,
                  typeid(multiset<void*>), DefineBehavior(ptr, ptr),
                  0, &multisetlEvoidmUgR_Dictionary, isa_proxy, 0,
                  sizeof(multiset<void*>) );
      instance.SetNew(&new_multisetlEvoidmUgR);
      instance.SetNewArray(&newArray_multisetlEvoidmUgR);
      instance.SetDelete(&delete_multisetlEvoidmUgR);
      instance.SetDeleteArray(&deleteArray_multisetlEvoidmUgR);
      instance.SetDestructor(&destruct_multisetlEvoidmUgR);
      instance.AdoptCollectionProxyInfo(TCollectionProxyInfo::Generate(TCollectionProxyInfo::Insert< multiset<void*> >()));
      return &instance;
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const multiset<void*>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void multisetlEvoidmUgR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const multiset<void*>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_multisetlEvoidmUgR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) multiset<void*> : new multiset<void*>;
   }
   static void *newArray_multisetlEvoidmUgR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) multiset<void*>[nElements] : new multiset<void*>[nElements];
   }
   // Wrapper around operator delete
   static void delete_multisetlEvoidmUgR(void *p) {
      delete ((multiset<void*>*)p);
   }
   static void deleteArray_multisetlEvoidmUgR(void *p) {
      delete [] ((multiset<void*>*)p);
   }
   static void destruct_multisetlEvoidmUgR(void *p) {
      typedef multiset<void*> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class multiset<void*>

/********************************************************
* cint/cint/lib/dll_stl/rootcint_multiset.cxx
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

extern "C" void G__cpp_reset_tagtablerootcint_multiset();

extern "C" void G__set_cpp_environmentrootcint_multiset() {
  G__add_compiledheader("TObject.h");
  G__add_compiledheader("TMemberInspector.h");
  G__add_compiledheader("set");
  G__cpp_reset_tagtablerootcint_multiset();
}
#include <new>
extern "C" int G__cpp_dllrevrootcint_multiset() { return(30051515); }

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
class G__Sizep2memfuncrootcint_multiset {
 public:
  G__Sizep2memfuncrootcint_multiset(): p(&G__Sizep2memfuncrootcint_multiset::sizep2memfunc) {}
    size_t sizep2memfunc() { return(sizeof(p)); }
  private:
    size_t (G__Sizep2memfuncrootcint_multiset::*p)();
};

size_t G__get_sizep2memfuncrootcint_multiset()
{
  G__Sizep2memfuncrootcint_multiset a;
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
extern "C" void G__cpp_setup_inheritancerootcint_multiset() {

   /* Setting up class inheritance */
}

/*********************************************************
* typedef information setup/
*********************************************************/
extern "C" void G__cpp_setup_typetablerootcint_multiset() {

   /* Setting up typedef entry */
   G__search_typename2("vector<ROOT::TSchemaHelper>",117,G__get_linked_tagnum(&G__rootcint_multisetLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR),0,-1);
   G__setnewtype(-1,NULL,0);
   G__search_typename2("reverse_iterator<const_iterator>",117,G__get_linked_tagnum(&G__rootcint_multisetLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR),0,G__get_linked_tagnum(&G__rootcint_multisetLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR));
   G__setnewtype(-1,NULL,0);
   G__search_typename2("reverse_iterator<iterator>",117,G__get_linked_tagnum(&G__rootcint_multisetLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR),0,G__get_linked_tagnum(&G__rootcint_multisetLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR));
   G__setnewtype(-1,NULL,0);
   G__search_typename2("vector<TVirtualArray*>",117,G__get_linked_tagnum(&G__rootcint_multisetLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR),0,-1);
   G__setnewtype(-1,NULL,0);
   G__search_typename2("reverse_iterator<const_iterator>",117,G__get_linked_tagnum(&G__rootcint_multisetLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR),0,G__get_linked_tagnum(&G__rootcint_multisetLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR));
   G__setnewtype(-1,NULL,0);
   G__search_typename2("reverse_iterator<iterator>",117,G__get_linked_tagnum(&G__rootcint_multisetLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR),0,G__get_linked_tagnum(&G__rootcint_multisetLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR));
   G__setnewtype(-1,NULL,0);
}

/*********************************************************
* Data Member information setup/
*********************************************************/

   /* Setting up class,struct,union tag member variable */
extern "C" void G__cpp_setup_memvarrootcint_multiset() {
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
extern "C" void G__cpp_setup_memfuncrootcint_multiset() {
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
extern "C" void G__cpp_setup_globalrootcint_multiset() {
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

extern "C" void G__cpp_setup_funcrootcint_multiset() {
  G__cpp_setup_func0();
  G__cpp_setup_func1();
  G__cpp_setup_func2();
}

/*********************************************************
* Class,struct,union,enum tag information setup
*********************************************************/
/* Setup class/struct taginfo */
G__linked_taginfo G__rootcint_multisetLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR = { "vector<ROOT::TSchemaHelper,allocator<ROOT::TSchemaHelper> >" , 99 , -1 };
G__linked_taginfo G__rootcint_multisetLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR = { "reverse_iterator<vector<ROOT::TSchemaHelper,allocator<ROOT::TSchemaHelper> >::iterator>" , 99 , -1 };
G__linked_taginfo G__rootcint_multisetLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR = { "vector<TVirtualArray*,allocator<TVirtualArray*> >" , 99 , -1 };
G__linked_taginfo G__rootcint_multisetLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR = { "reverse_iterator<vector<TVirtualArray*,allocator<TVirtualArray*> >::iterator>" , 99 , -1 };

/* Reset class/struct taginfo */
extern "C" void G__cpp_reset_tagtablerootcint_multiset() {
  G__rootcint_multisetLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR.tagnum = -1 ;
  G__rootcint_multisetLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR.tagnum = -1 ;
  G__rootcint_multisetLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR.tagnum = -1 ;
  G__rootcint_multisetLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR.tagnum = -1 ;
}


extern "C" void G__cpp_setup_tagtablerootcint_multiset() {

   /* Setting up class,struct,union tag entry */
   G__get_linked_tagnum_fwd(&G__rootcint_multisetLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR);
   G__get_linked_tagnum_fwd(&G__rootcint_multisetLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR);
   G__get_linked_tagnum_fwd(&G__rootcint_multisetLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR);
   G__get_linked_tagnum_fwd(&G__rootcint_multisetLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR);
}
extern "C" void G__cpp_setuprootcint_multiset(void) {
  G__check_setup_version(30051515,"G__cpp_setuprootcint_multiset()");
  G__set_cpp_environmentrootcint_multiset();
  G__cpp_setup_tagtablerootcint_multiset();

  G__cpp_setup_inheritancerootcint_multiset();

  G__cpp_setup_typetablerootcint_multiset();

  G__cpp_setup_memvarrootcint_multiset();

  G__cpp_setup_memfuncrootcint_multiset();
  G__cpp_setup_globalrootcint_multiset();
  G__cpp_setup_funcrootcint_multiset();

   if(0==G__getsizep2memfunc()) G__get_sizep2memfuncrootcint_multiset();
  return;
}
class G__cpp_setup_initrootcint_multiset {
  public:
    G__cpp_setup_initrootcint_multiset() { G__add_setup_func("rootcint_multiset",(G__incsetup)(&G__cpp_setuprootcint_multiset)); G__call_setup_funcs(); }
   ~G__cpp_setup_initrootcint_multiset() { G__remove_setup_func("rootcint_multiset"); }
};
G__cpp_setup_initrootcint_multiset G__cpp_setup_initializerrootcint_multiset;

