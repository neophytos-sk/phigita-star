//
// File generated by core/utils/src/rootcint_tmp at Sat Jan 22 22:07:09 2011

// Do NOT change. Changes will be lost next time file is generated
//

#define R__DICTIONARY_FILENAME cintdIcintdIlibdIdll_stldIrootcint_multimap
#include "RConfig.h" //rootcint 4834
#if !defined(R__ACCESS_IN_SYMBOL)
//Break the privacy of classes -- Disabled for the moment
#define private public
#define protected public
#endif

// Since CINT ignores the std namespace, we need to do so in this file.
namespace std {} using namespace std;
#include "rootcint_multimap.h"

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
   void multimaplEcharmUcOcharmUgR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void multimaplEcharmUcOcharmUgR_Dictionary();
   static void *new_multimaplEcharmUcOcharmUgR(void *p = 0);
   static void *newArray_multimaplEcharmUcOcharmUgR(Long_t size, void *p);
   static void delete_multimaplEcharmUcOcharmUgR(void *p);
   static void deleteArray_multimaplEcharmUcOcharmUgR(void *p);
   static void destruct_multimaplEcharmUcOcharmUgR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const multimap<char*,char*>*)
   {
      multimap<char*,char*> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(multimap<char*,char*>),0);
      static ::ROOT::TGenericClassInfo 
         instance("multimap<char*,char*>", -2, "prec_stl/multimap", 63,
                  typeid(multimap<char*,char*>), DefineBehavior(ptr, ptr),
                  0, &multimaplEcharmUcOcharmUgR_Dictionary, isa_proxy, 0,
                  sizeof(multimap<char*,char*>) );
      instance.SetNew(&new_multimaplEcharmUcOcharmUgR);
      instance.SetNewArray(&newArray_multimaplEcharmUcOcharmUgR);
      instance.SetDelete(&delete_multimaplEcharmUcOcharmUgR);
      instance.SetDeleteArray(&deleteArray_multimaplEcharmUcOcharmUgR);
      instance.SetDestructor(&destruct_multimaplEcharmUcOcharmUgR);
      instance.AdoptCollectionProxyInfo(TCollectionProxyInfo::Generate(TCollectionProxyInfo::MapInsert< multimap<char*,char*> >()));
      return &instance;
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const multimap<char*,char*>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void multimaplEcharmUcOcharmUgR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const multimap<char*,char*>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_multimaplEcharmUcOcharmUgR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<char*,char*> : new multimap<char*,char*>;
   }
   static void *newArray_multimaplEcharmUcOcharmUgR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<char*,char*>[nElements] : new multimap<char*,char*>[nElements];
   }
   // Wrapper around operator delete
   static void delete_multimaplEcharmUcOcharmUgR(void *p) {
      delete ((multimap<char*,char*>*)p);
   }
   static void deleteArray_multimaplEcharmUcOcharmUgR(void *p) {
      delete [] ((multimap<char*,char*>*)p);
   }
   static void destruct_multimaplEcharmUcOcharmUgR(void *p) {
      typedef multimap<char*,char*> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class multimap<char*,char*>

namespace ROOT {
   void multimaplEcharmUcOdoublegR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void multimaplEcharmUcOdoublegR_Dictionary();
   static void *new_multimaplEcharmUcOdoublegR(void *p = 0);
   static void *newArray_multimaplEcharmUcOdoublegR(Long_t size, void *p);
   static void delete_multimaplEcharmUcOdoublegR(void *p);
   static void deleteArray_multimaplEcharmUcOdoublegR(void *p);
   static void destruct_multimaplEcharmUcOdoublegR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const multimap<char*,double>*)
   {
      multimap<char*,double> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(multimap<char*,double>),0);
      static ::ROOT::TGenericClassInfo 
         instance("multimap<char*,double>", -2, "prec_stl/multimap", 63,
                  typeid(multimap<char*,double>), DefineBehavior(ptr, ptr),
                  0, &multimaplEcharmUcOdoublegR_Dictionary, isa_proxy, 0,
                  sizeof(multimap<char*,double>) );
      instance.SetNew(&new_multimaplEcharmUcOdoublegR);
      instance.SetNewArray(&newArray_multimaplEcharmUcOdoublegR);
      instance.SetDelete(&delete_multimaplEcharmUcOdoublegR);
      instance.SetDeleteArray(&deleteArray_multimaplEcharmUcOdoublegR);
      instance.SetDestructor(&destruct_multimaplEcharmUcOdoublegR);
      instance.AdoptCollectionProxyInfo(TCollectionProxyInfo::Generate(TCollectionProxyInfo::MapInsert< multimap<char*,double> >()));
      return &instance;
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const multimap<char*,double>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void multimaplEcharmUcOdoublegR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const multimap<char*,double>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_multimaplEcharmUcOdoublegR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<char*,double> : new multimap<char*,double>;
   }
   static void *newArray_multimaplEcharmUcOdoublegR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<char*,double>[nElements] : new multimap<char*,double>[nElements];
   }
   // Wrapper around operator delete
   static void delete_multimaplEcharmUcOdoublegR(void *p) {
      delete ((multimap<char*,double>*)p);
   }
   static void deleteArray_multimaplEcharmUcOdoublegR(void *p) {
      delete [] ((multimap<char*,double>*)p);
   }
   static void destruct_multimaplEcharmUcOdoublegR(void *p) {
      typedef multimap<char*,double> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class multimap<char*,double>

namespace ROOT {
   void multimaplEcharmUcOintgR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void multimaplEcharmUcOintgR_Dictionary();
   static void *new_multimaplEcharmUcOintgR(void *p = 0);
   static void *newArray_multimaplEcharmUcOintgR(Long_t size, void *p);
   static void delete_multimaplEcharmUcOintgR(void *p);
   static void deleteArray_multimaplEcharmUcOintgR(void *p);
   static void destruct_multimaplEcharmUcOintgR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const multimap<char*,int>*)
   {
      multimap<char*,int> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(multimap<char*,int>),0);
      static ::ROOT::TGenericClassInfo 
         instance("multimap<char*,int>", -2, "prec_stl/multimap", 63,
                  typeid(multimap<char*,int>), DefineBehavior(ptr, ptr),
                  0, &multimaplEcharmUcOintgR_Dictionary, isa_proxy, 0,
                  sizeof(multimap<char*,int>) );
      instance.SetNew(&new_multimaplEcharmUcOintgR);
      instance.SetNewArray(&newArray_multimaplEcharmUcOintgR);
      instance.SetDelete(&delete_multimaplEcharmUcOintgR);
      instance.SetDeleteArray(&deleteArray_multimaplEcharmUcOintgR);
      instance.SetDestructor(&destruct_multimaplEcharmUcOintgR);
      instance.AdoptCollectionProxyInfo(TCollectionProxyInfo::Generate(TCollectionProxyInfo::MapInsert< multimap<char*,int> >()));
      return &instance;
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const multimap<char*,int>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void multimaplEcharmUcOintgR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const multimap<char*,int>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_multimaplEcharmUcOintgR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<char*,int> : new multimap<char*,int>;
   }
   static void *newArray_multimaplEcharmUcOintgR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<char*,int>[nElements] : new multimap<char*,int>[nElements];
   }
   // Wrapper around operator delete
   static void delete_multimaplEcharmUcOintgR(void *p) {
      delete ((multimap<char*,int>*)p);
   }
   static void deleteArray_multimaplEcharmUcOintgR(void *p) {
      delete [] ((multimap<char*,int>*)p);
   }
   static void destruct_multimaplEcharmUcOintgR(void *p) {
      typedef multimap<char*,int> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class multimap<char*,int>

namespace ROOT {
   void multimaplEcharmUcOlonggR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void multimaplEcharmUcOlonggR_Dictionary();
   static void *new_multimaplEcharmUcOlonggR(void *p = 0);
   static void *newArray_multimaplEcharmUcOlonggR(Long_t size, void *p);
   static void delete_multimaplEcharmUcOlonggR(void *p);
   static void deleteArray_multimaplEcharmUcOlonggR(void *p);
   static void destruct_multimaplEcharmUcOlonggR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const multimap<char*,long>*)
   {
      multimap<char*,long> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(multimap<char*,long>),0);
      static ::ROOT::TGenericClassInfo 
         instance("multimap<char*,long>", -2, "prec_stl/multimap", 63,
                  typeid(multimap<char*,long>), DefineBehavior(ptr, ptr),
                  0, &multimaplEcharmUcOlonggR_Dictionary, isa_proxy, 0,
                  sizeof(multimap<char*,long>) );
      instance.SetNew(&new_multimaplEcharmUcOlonggR);
      instance.SetNewArray(&newArray_multimaplEcharmUcOlonggR);
      instance.SetDelete(&delete_multimaplEcharmUcOlonggR);
      instance.SetDeleteArray(&deleteArray_multimaplEcharmUcOlonggR);
      instance.SetDestructor(&destruct_multimaplEcharmUcOlonggR);
      instance.AdoptCollectionProxyInfo(TCollectionProxyInfo::Generate(TCollectionProxyInfo::MapInsert< multimap<char*,long> >()));
      return &instance;
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const multimap<char*,long>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void multimaplEcharmUcOlonggR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const multimap<char*,long>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_multimaplEcharmUcOlonggR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<char*,long> : new multimap<char*,long>;
   }
   static void *newArray_multimaplEcharmUcOlonggR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<char*,long>[nElements] : new multimap<char*,long>[nElements];
   }
   // Wrapper around operator delete
   static void delete_multimaplEcharmUcOlonggR(void *p) {
      delete ((multimap<char*,long>*)p);
   }
   static void deleteArray_multimaplEcharmUcOlonggR(void *p) {
      delete [] ((multimap<char*,long>*)p);
   }
   static void destruct_multimaplEcharmUcOlonggR(void *p) {
      typedef multimap<char*,long> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class multimap<char*,long>

namespace ROOT {
   void multimaplEcharmUcOvoidmUgR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void multimaplEcharmUcOvoidmUgR_Dictionary();
   static void *new_multimaplEcharmUcOvoidmUgR(void *p = 0);
   static void *newArray_multimaplEcharmUcOvoidmUgR(Long_t size, void *p);
   static void delete_multimaplEcharmUcOvoidmUgR(void *p);
   static void deleteArray_multimaplEcharmUcOvoidmUgR(void *p);
   static void destruct_multimaplEcharmUcOvoidmUgR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const multimap<char*,void*>*)
   {
      multimap<char*,void*> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(multimap<char*,void*>),0);
      static ::ROOT::TGenericClassInfo 
         instance("multimap<char*,void*>", -2, "prec_stl/multimap", 63,
                  typeid(multimap<char*,void*>), DefineBehavior(ptr, ptr),
                  0, &multimaplEcharmUcOvoidmUgR_Dictionary, isa_proxy, 0,
                  sizeof(multimap<char*,void*>) );
      instance.SetNew(&new_multimaplEcharmUcOvoidmUgR);
      instance.SetNewArray(&newArray_multimaplEcharmUcOvoidmUgR);
      instance.SetDelete(&delete_multimaplEcharmUcOvoidmUgR);
      instance.SetDeleteArray(&deleteArray_multimaplEcharmUcOvoidmUgR);
      instance.SetDestructor(&destruct_multimaplEcharmUcOvoidmUgR);
      instance.AdoptCollectionProxyInfo(TCollectionProxyInfo::Generate(TCollectionProxyInfo::MapInsert< multimap<char*,void*> >()));
      return &instance;
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const multimap<char*,void*>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void multimaplEcharmUcOvoidmUgR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const multimap<char*,void*>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_multimaplEcharmUcOvoidmUgR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<char*,void*> : new multimap<char*,void*>;
   }
   static void *newArray_multimaplEcharmUcOvoidmUgR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<char*,void*>[nElements] : new multimap<char*,void*>[nElements];
   }
   // Wrapper around operator delete
   static void delete_multimaplEcharmUcOvoidmUgR(void *p) {
      delete ((multimap<char*,void*>*)p);
   }
   static void deleteArray_multimaplEcharmUcOvoidmUgR(void *p) {
      delete [] ((multimap<char*,void*>*)p);
   }
   static void destruct_multimaplEcharmUcOvoidmUgR(void *p) {
      typedef multimap<char*,void*> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class multimap<char*,void*>

namespace ROOT {
   void multimaplEstringcOdoublegR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void multimaplEstringcOdoublegR_Dictionary();
   static void *new_multimaplEstringcOdoublegR(void *p = 0);
   static void *newArray_multimaplEstringcOdoublegR(Long_t size, void *p);
   static void delete_multimaplEstringcOdoublegR(void *p);
   static void deleteArray_multimaplEstringcOdoublegR(void *p);
   static void destruct_multimaplEstringcOdoublegR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const multimap<string,double>*)
   {
      multimap<string,double> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(multimap<string,double>),0);
      static ::ROOT::TGenericClassInfo 
         instance("multimap<string,double>", -2, "prec_stl/multimap", 63,
                  typeid(multimap<string,double>), DefineBehavior(ptr, ptr),
                  0, &multimaplEstringcOdoublegR_Dictionary, isa_proxy, 0,
                  sizeof(multimap<string,double>) );
      instance.SetNew(&new_multimaplEstringcOdoublegR);
      instance.SetNewArray(&newArray_multimaplEstringcOdoublegR);
      instance.SetDelete(&delete_multimaplEstringcOdoublegR);
      instance.SetDeleteArray(&deleteArray_multimaplEstringcOdoublegR);
      instance.SetDestructor(&destruct_multimaplEstringcOdoublegR);
      instance.AdoptCollectionProxyInfo(TCollectionProxyInfo::Generate(TCollectionProxyInfo::MapInsert< multimap<string,double> >()));
      return &instance;
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const multimap<string,double>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void multimaplEstringcOdoublegR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const multimap<string,double>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_multimaplEstringcOdoublegR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<string,double> : new multimap<string,double>;
   }
   static void *newArray_multimaplEstringcOdoublegR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<string,double>[nElements] : new multimap<string,double>[nElements];
   }
   // Wrapper around operator delete
   static void delete_multimaplEstringcOdoublegR(void *p) {
      delete ((multimap<string,double>*)p);
   }
   static void deleteArray_multimaplEstringcOdoublegR(void *p) {
      delete [] ((multimap<string,double>*)p);
   }
   static void destruct_multimaplEstringcOdoublegR(void *p) {
      typedef multimap<string,double> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class multimap<string,double>

namespace ROOT {
   void multimaplEstringcOintgR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void multimaplEstringcOintgR_Dictionary();
   static void *new_multimaplEstringcOintgR(void *p = 0);
   static void *newArray_multimaplEstringcOintgR(Long_t size, void *p);
   static void delete_multimaplEstringcOintgR(void *p);
   static void deleteArray_multimaplEstringcOintgR(void *p);
   static void destruct_multimaplEstringcOintgR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const multimap<string,int>*)
   {
      multimap<string,int> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(multimap<string,int>),0);
      static ::ROOT::TGenericClassInfo 
         instance("multimap<string,int>", -2, "prec_stl/multimap", 63,
                  typeid(multimap<string,int>), DefineBehavior(ptr, ptr),
                  0, &multimaplEstringcOintgR_Dictionary, isa_proxy, 0,
                  sizeof(multimap<string,int>) );
      instance.SetNew(&new_multimaplEstringcOintgR);
      instance.SetNewArray(&newArray_multimaplEstringcOintgR);
      instance.SetDelete(&delete_multimaplEstringcOintgR);
      instance.SetDeleteArray(&deleteArray_multimaplEstringcOintgR);
      instance.SetDestructor(&destruct_multimaplEstringcOintgR);
      instance.AdoptCollectionProxyInfo(TCollectionProxyInfo::Generate(TCollectionProxyInfo::MapInsert< multimap<string,int> >()));
      return &instance;
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const multimap<string,int>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void multimaplEstringcOintgR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const multimap<string,int>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_multimaplEstringcOintgR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<string,int> : new multimap<string,int>;
   }
   static void *newArray_multimaplEstringcOintgR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<string,int>[nElements] : new multimap<string,int>[nElements];
   }
   // Wrapper around operator delete
   static void delete_multimaplEstringcOintgR(void *p) {
      delete ((multimap<string,int>*)p);
   }
   static void deleteArray_multimaplEstringcOintgR(void *p) {
      delete [] ((multimap<string,int>*)p);
   }
   static void destruct_multimaplEstringcOintgR(void *p) {
      typedef multimap<string,int> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class multimap<string,int>

namespace ROOT {
   void multimaplEstringcOlonggR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void multimaplEstringcOlonggR_Dictionary();
   static void *new_multimaplEstringcOlonggR(void *p = 0);
   static void *newArray_multimaplEstringcOlonggR(Long_t size, void *p);
   static void delete_multimaplEstringcOlonggR(void *p);
   static void deleteArray_multimaplEstringcOlonggR(void *p);
   static void destruct_multimaplEstringcOlonggR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const multimap<string,long>*)
   {
      multimap<string,long> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(multimap<string,long>),0);
      static ::ROOT::TGenericClassInfo 
         instance("multimap<string,long>", -2, "prec_stl/multimap", 63,
                  typeid(multimap<string,long>), DefineBehavior(ptr, ptr),
                  0, &multimaplEstringcOlonggR_Dictionary, isa_proxy, 0,
                  sizeof(multimap<string,long>) );
      instance.SetNew(&new_multimaplEstringcOlonggR);
      instance.SetNewArray(&newArray_multimaplEstringcOlonggR);
      instance.SetDelete(&delete_multimaplEstringcOlonggR);
      instance.SetDeleteArray(&deleteArray_multimaplEstringcOlonggR);
      instance.SetDestructor(&destruct_multimaplEstringcOlonggR);
      instance.AdoptCollectionProxyInfo(TCollectionProxyInfo::Generate(TCollectionProxyInfo::MapInsert< multimap<string,long> >()));
      return &instance;
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const multimap<string,long>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void multimaplEstringcOlonggR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const multimap<string,long>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_multimaplEstringcOlonggR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<string,long> : new multimap<string,long>;
   }
   static void *newArray_multimaplEstringcOlonggR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<string,long>[nElements] : new multimap<string,long>[nElements];
   }
   // Wrapper around operator delete
   static void delete_multimaplEstringcOlonggR(void *p) {
      delete ((multimap<string,long>*)p);
   }
   static void deleteArray_multimaplEstringcOlonggR(void *p) {
      delete [] ((multimap<string,long>*)p);
   }
   static void destruct_multimaplEstringcOlonggR(void *p) {
      typedef multimap<string,long> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class multimap<string,long>

namespace ROOT {
   void multimaplEstringcOvoidmUgR_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void multimaplEstringcOvoidmUgR_Dictionary();
   static void *new_multimaplEstringcOvoidmUgR(void *p = 0);
   static void *newArray_multimaplEstringcOvoidmUgR(Long_t size, void *p);
   static void delete_multimaplEstringcOvoidmUgR(void *p);
   static void deleteArray_multimaplEstringcOvoidmUgR(void *p);
   static void destruct_multimaplEstringcOvoidmUgR(void *p);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const multimap<string,void*>*)
   {
      multimap<string,void*> *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TIsAProxy(typeid(multimap<string,void*>),0);
      static ::ROOT::TGenericClassInfo 
         instance("multimap<string,void*>", -2, "prec_stl/multimap", 63,
                  typeid(multimap<string,void*>), DefineBehavior(ptr, ptr),
                  0, &multimaplEstringcOvoidmUgR_Dictionary, isa_proxy, 0,
                  sizeof(multimap<string,void*>) );
      instance.SetNew(&new_multimaplEstringcOvoidmUgR);
      instance.SetNewArray(&newArray_multimaplEstringcOvoidmUgR);
      instance.SetDelete(&delete_multimaplEstringcOvoidmUgR);
      instance.SetDeleteArray(&deleteArray_multimaplEstringcOvoidmUgR);
      instance.SetDestructor(&destruct_multimaplEstringcOvoidmUgR);
      instance.AdoptCollectionProxyInfo(TCollectionProxyInfo::Generate(TCollectionProxyInfo::MapInsert< multimap<string,void*> >()));
      return &instance;
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const multimap<string,void*>*)0x0); R__UseDummy(_R__UNIQUE_(Init));

   // Dictionary for non-ClassDef classes
   static void multimaplEstringcOvoidmUgR_Dictionary() {
      ::ROOT::GenerateInitInstanceLocal((const multimap<string,void*>*)0x0)->GetClass();
   }

} // end of namespace ROOT

namespace ROOT {
   // Wrappers around operator new
   static void *new_multimaplEstringcOvoidmUgR(void *p) {
      return  p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<string,void*> : new multimap<string,void*>;
   }
   static void *newArray_multimaplEstringcOvoidmUgR(Long_t nElements, void *p) {
      return p ? ::new((::ROOT::TOperatorNewHelper*)p) multimap<string,void*>[nElements] : new multimap<string,void*>[nElements];
   }
   // Wrapper around operator delete
   static void delete_multimaplEstringcOvoidmUgR(void *p) {
      delete ((multimap<string,void*>*)p);
   }
   static void deleteArray_multimaplEstringcOvoidmUgR(void *p) {
      delete [] ((multimap<string,void*>*)p);
   }
   static void destruct_multimaplEstringcOvoidmUgR(void *p) {
      typedef multimap<string,void*> current_t;
      ((current_t*)p)->~current_t();
   }
} // end of namespace ROOT for class multimap<string,void*>

/********************************************************
* cint/cint/lib/dll_stl/rootcint_multimap.cxx
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

extern "C" void G__cpp_reset_tagtablerootcint_multimap();

extern "C" void G__set_cpp_environmentrootcint_multimap() {
  G__add_compiledheader("TObject.h");
  G__add_compiledheader("TMemberInspector.h");
  G__add_compiledheader("map");
  G__cpp_reset_tagtablerootcint_multimap();
}
#include <new>
extern "C" int G__cpp_dllrevrootcint_multimap() { return(30051515); }

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
class G__Sizep2memfuncrootcint_multimap {
 public:
  G__Sizep2memfuncrootcint_multimap(): p(&G__Sizep2memfuncrootcint_multimap::sizep2memfunc) {}
    size_t sizep2memfunc() { return(sizeof(p)); }
  private:
    size_t (G__Sizep2memfuncrootcint_multimap::*p)();
};

size_t G__get_sizep2memfuncrootcint_multimap()
{
  G__Sizep2memfuncrootcint_multimap a;
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
extern "C" void G__cpp_setup_inheritancerootcint_multimap() {

   /* Setting up class inheritance */
}

/*********************************************************
* typedef information setup/
*********************************************************/
extern "C" void G__cpp_setup_typetablerootcint_multimap() {

   /* Setting up typedef entry */
   G__search_typename2("vector<ROOT::TSchemaHelper>",117,G__get_linked_tagnum(&G__rootcint_multimapLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR),0,-1);
   G__setnewtype(-1,NULL,0);
   G__search_typename2("reverse_iterator<const_iterator>",117,G__get_linked_tagnum(&G__rootcint_multimapLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR),0,G__get_linked_tagnum(&G__rootcint_multimapLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR));
   G__setnewtype(-1,NULL,0);
   G__search_typename2("reverse_iterator<iterator>",117,G__get_linked_tagnum(&G__rootcint_multimapLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR),0,G__get_linked_tagnum(&G__rootcint_multimapLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR));
   G__setnewtype(-1,NULL,0);
   G__search_typename2("vector<TVirtualArray*>",117,G__get_linked_tagnum(&G__rootcint_multimapLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR),0,-1);
   G__setnewtype(-1,NULL,0);
   G__search_typename2("reverse_iterator<const_iterator>",117,G__get_linked_tagnum(&G__rootcint_multimapLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR),0,G__get_linked_tagnum(&G__rootcint_multimapLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR));
   G__setnewtype(-1,NULL,0);
   G__search_typename2("reverse_iterator<iterator>",117,G__get_linked_tagnum(&G__rootcint_multimapLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR),0,G__get_linked_tagnum(&G__rootcint_multimapLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR));
   G__setnewtype(-1,NULL,0);
}

/*********************************************************
* Data Member information setup/
*********************************************************/

   /* Setting up class,struct,union tag member variable */
extern "C" void G__cpp_setup_memvarrootcint_multimap() {
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
extern "C" void G__cpp_setup_memfuncrootcint_multimap() {
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
extern "C" void G__cpp_setup_globalrootcint_multimap() {
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

extern "C" void G__cpp_setup_funcrootcint_multimap() {
  G__cpp_setup_func0();
  G__cpp_setup_func1();
  G__cpp_setup_func2();
}

/*********************************************************
* Class,struct,union,enum tag information setup
*********************************************************/
/* Setup class/struct taginfo */
G__linked_taginfo G__rootcint_multimapLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR = { "vector<ROOT::TSchemaHelper,allocator<ROOT::TSchemaHelper> >" , 99 , -1 };
G__linked_taginfo G__rootcint_multimapLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR = { "reverse_iterator<vector<ROOT::TSchemaHelper,allocator<ROOT::TSchemaHelper> >::iterator>" , 99 , -1 };
G__linked_taginfo G__rootcint_multimapLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR = { "vector<TVirtualArray*,allocator<TVirtualArray*> >" , 99 , -1 };
G__linked_taginfo G__rootcint_multimapLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR = { "reverse_iterator<vector<TVirtualArray*,allocator<TVirtualArray*> >::iterator>" , 99 , -1 };

/* Reset class/struct taginfo */
extern "C" void G__cpp_reset_tagtablerootcint_multimap() {
  G__rootcint_multimapLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR.tagnum = -1 ;
  G__rootcint_multimapLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR.tagnum = -1 ;
  G__rootcint_multimapLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR.tagnum = -1 ;
  G__rootcint_multimapLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR.tagnum = -1 ;
}


extern "C" void G__cpp_setup_tagtablerootcint_multimap() {

   /* Setting up class,struct,union tag entry */
   G__get_linked_tagnum_fwd(&G__rootcint_multimapLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR);
   G__get_linked_tagnum_fwd(&G__rootcint_multimapLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR);
   G__get_linked_tagnum_fwd(&G__rootcint_multimapLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR);
   G__get_linked_tagnum_fwd(&G__rootcint_multimapLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR);
}
extern "C" void G__cpp_setuprootcint_multimap(void) {
  G__check_setup_version(30051515,"G__cpp_setuprootcint_multimap()");
  G__set_cpp_environmentrootcint_multimap();
  G__cpp_setup_tagtablerootcint_multimap();

  G__cpp_setup_inheritancerootcint_multimap();

  G__cpp_setup_typetablerootcint_multimap();

  G__cpp_setup_memvarrootcint_multimap();

  G__cpp_setup_memfuncrootcint_multimap();
  G__cpp_setup_globalrootcint_multimap();
  G__cpp_setup_funcrootcint_multimap();

   if(0==G__getsizep2memfunc()) G__get_sizep2memfuncrootcint_multimap();
  return;
}
class G__cpp_setup_initrootcint_multimap {
  public:
    G__cpp_setup_initrootcint_multimap() { G__add_setup_func("rootcint_multimap",(G__incsetup)(&G__cpp_setuprootcint_multimap)); G__call_setup_funcs(); }
   ~G__cpp_setup_initrootcint_multimap() { G__remove_setup_func("rootcint_multimap"); }
};
G__cpp_setup_initrootcint_multimap G__cpp_setup_initializerrootcint_multimap;

