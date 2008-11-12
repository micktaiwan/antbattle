//---------------------------------------------------------------------------
#ifdef WIN32
#pragma hdrstop
#pragma package(smart_init)
#endif

#include "MThread.h"

#include <string>
extern void WriteToLog(int, const std::string&);

//---------------------------------------------------------------------------
void MThread::Start() {

   if(Thread) Stop();
   SetActive(true);
   Thread = new boost::thread(boost::ref(*this));

   }

//---------------------------------------------------------------------------
void MThread::Stop() {

   SetActive(false);
   if(!Thread) return;
   Thread->join();
   delete Thread;
   Thread = NULL;

   }

