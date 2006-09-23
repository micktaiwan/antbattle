//---------------------------------------------------------------------------
#include <string>
#include <iostream>
#include <signal.h>
#include "AntServer.h"
#include <boost/thread/thread.hpp>
#ifdef WIN32
#pragma argsused
#endif
using namespace std;

bool SigInt = false;
string ProgramName = "AntBattle Server 0.5.4 (2006/09/14)"; // server banner
int gLoglevel = 3;
boost::mutex LogMutex;

//---------------------------------------------------------------------------
string sanitize(const string& str) {

   string rv;
   int l = str.size();
   for(int i=0; i < l;++i) {
      if(str[i]<32) rv += '/';
      else rv += str[i];
      }
   return rv;

   }

//---------------------------------------------------------------------------
void WriteToLog(int level, const string& str) {

   boost::mutex::scoped_lock lock(LogMutex);
   if(level <= gLoglevel) cout << sanitize(str) << endl;

   }

//---------------------------------------------------------------------------
void catch_int(int /*sig_num*/) {

   // reset the signal handler again to catch_int, for next time
   //signal(SIGINT, catch_int);
   cout << "SigInt catched" << endl;
   SigInt = true;

   }

//---------------------------------------------------------------------------
void usage() {
   cout << endl << "usage: AntBattleServer [port [loglevel [HTTP port]]]" << endl;
   cout << "default: port is 5000, loglevel is 3" << endl;
   cout << "set log level to 1 to have only errors, to 2 to skip debug messages\n\n";
   exit(1);
   }

//---------------------------------------------------------------------------
int main(int argc, char* argv[]) {

   signal(SIGINT, catch_int);
   signal(SIGPIPE,SIG_IGN);

   try {
      cout << ProgramName << endl;
      int port = 5000;
      int http_port = 8080;
      if(argc > 1 && (argv[1][0]=='/' || argv[1][0]=='-')) usage();
      if(argc > 1) port = atoi(argv[1]);
      if(argc > 2) gLoglevel = atoi(argv[2]);
      if(argc > 3) http_port = atoi(argv[3]);
      MAntServer s;
      s.SetHTTPPort(http_port);
      s.Run(port);
      }
   catch(exception& e) {
      cout << e.what() << endl;
      }
   catch(...) {
      cout << "Exception catched" << endl;
      }
   return 0;

   }
   
//---------------------------------------------------------------------------
