//---------------------------------------------------------------------------
#ifdef WIN32
#pragma hdrstop
#pragma package(smart_init)
#endif

#include "MStats.h"
#include "MUtils.h"

//---------------------------------------------------------------------------
MStat* MClientStats::Add(const std::string& name) {
   MStat* rv = Get(name);
   if(rv!=NULL) {
      rv->LastConn = MUtils::MyNow(1);
      return rv;
      }
   MStat* s = new MStat();
   s->Name = name;
   s->LastConn = MUtils::MyNow(1);
   List.push_back(s);
   return s;
   }

//---------------------------------------------------------------------------
MStat* MClientStats::SafeGet(const std::string& name) {
   return Add(name);
   }

//---------------------------------------------------------------------------
MStat* MClientStats::Get(const std::string& name) {

   MList::iterator ite = List.begin();
   while(ite!=List.end()) {
      if ((*ite)->Name==name) return (*ite);
      ++ite;
      }

   return NULL;

   }


//---------------------------------------------------------------------------
void MClientStats::Clear() {

   MList::iterator ite = List.begin();
   while(ite!=List.end()) {
      delete (*ite);
      ++ite;
      }
   List.clear();

   }
