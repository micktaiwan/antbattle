//---------------------------------------------------------------------------
#include <string>
#include <iostream>
#include <signal.h>
#include "AntServer.h"
#include <boost/thread/thread.hpp>
#include <fstream>
#ifdef WIN32
#pragma argsused
#endif
using namespace std;

bool SigInt = false;
string ProgramName = "AntBattle Server 0.5.6 (2006/11/01)";
int gLoglevel = 3;
string gLogFile = "./log.txt";
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
   if(level <= gLoglevel) {
      if(gLogFile=="") cout << sanitize(str) << endl;
      else {
         ofstream file(gLogFile.c_str(),ios_base::app);
         file <<  sanitize(str) << endl;
         }
      }

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
void ParseMap(const string& path, MAntServer& s) {

   ifstream file(path.c_str());
   string line, param, value;
   int pos;
   if(!file) {
      WriteToLog(1,string("Can not find map file ")+path);
      return;
      }
   WriteToLog(2,"Reading map file...");
   int width  = 20;
   int height = 20;
   while(!file.eof()) {
      getline(file,line);
      if(line[0]=='#' || line == "") continue;
      pos = line.find ("=", 0);
      if(pos==-1) continue;
      param = line.substr(0,pos);
      value = line.substr(pos+1);
      if(param=="width") {width=atoi(value.c_str());s.SetMapSize(width,height);}
      else if(param=="height") {height=atoi(value.c_str());s.SetMapSize(width,height);}
      else if(param=="obs") {
         pos = value.find (",", 0);
         int x = atoi(value.substr(0,pos).c_str());
         int y = atoi(value.substr(pos+1).c_str());
         s.SetMapObs(x,y);
         //ostringstream o;
         //o << "obs: " << x << "," << y;
         //WriteToLog(3,o.str());
         }
      else cout << "Unknown param " << param << endl;
      }
   ostringstream o;
   o << "Map size: " << width << "x" << height;
   WriteToLog(2,o.str());

   }


//---------------------------------------------------------------------------
int main(int argc, char* argv[]) {

   signal(SIGINT, catch_int);
#if !defined(WIN32)
   signal(SIGPIPE,SIG_IGN);
#endif
   try {
      cout << ProgramName << endl;
      int port = 5000;
      int http_port = 8080;
      if(argc > 1 && (argv[1][0]=='/' || argv[1][0]=='-')) usage();
      if(argc > 1) port = atoi(argv[1]);
      if(argc > 2) gLoglevel = atoi(argv[2]);
      if(argc > 3) http_port = atoi(argv[3]);
      // open the config file
      MAntServer s;
      s.SetHTTPPort(http_port);
      ifstream file("./config.ini");
      string line, param, value;
      int pos;
      if(file) {
         WriteToLog(2,"Reading config file...");
         while(!file.eof()) {
            getline(file,line);
            if(line[0]=='#' || line == "") continue;
            pos = line.find ("=", 0);
            if(pos==-1) continue;
            //cout << line << endl;
            //cout << pos << endl;
            param = line.substr(0,pos);
            value = line.substr(pos+1);
            if(param=="port") port = atoi(value.c_str());
            else if(param=="http_port") s.SetHTTPPort(atoi(value.c_str()));
            else if(param=="log_level") gLoglevel = atoi(value.c_str());
            else if(param=="nb_ant") s.NbAnt = atoi(value.c_str());
            else if(param=="log_file") gLogFile = value;
            else if(param=="erase_log_on_start") {
               if(value=="yes") ofstream(gLogFile.c_str(),ios_base::out);
               }
            else if(param=="map") ParseMap(value,s);
            else cout << "Unknown param " << param << endl;
            //cout << param << "=" << value << endl;
            }
         }
      s.Run(port);
      }
   catch(exception& e) {
      WriteToLog(1, string("Exception: ")+e.what());
      }
   catch(...) {
      WriteToLog(1, "Exception catched");
      }
   return 0;

   }

//---------------------------------------------------------------------------
