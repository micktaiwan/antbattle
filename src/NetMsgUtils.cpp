#include "NetMsgUtils.h"
#include <sstream>
#include "MUtils.h"

using namespace std;

extern void WriteToLog(int t, const string& msg);

//---------------------------------------------------------------------------
string GetParam(const string& m, int n) {

   if(n==0) n = 1; // 1 based

   int i    = 2; // skip the first 2 netmsg category chars
   int ps   = 0; // paramsep counter
   const int size = m.size();
   string param;

   while(i < size) {
      if(m[i]==PARAMSEP) {
         ps++;   // we just passed a parameter
         i++;    // skip the PARAMSEP
         if(i==size) return param;
         continue; // added on 2004/04/20
         }
      if(ps==n) return param;    // that was it, param contains the last param
      if(ps==n-1) param += m[i]; // we are reading it
      i++;
      }       

   return param; // we read all the string

   }

//---------------------------------------------------------------------------
int GetIntParam(const string& m, int n) {

   int rv;
   stringstream o;
   o << GetParam(m,n);
   o >> rv;
   return rv;

   }

//---------------------------------------------------------------------------
string GetParamFrom(const string& m, int n) {

   string msg = string("xx")+m.substr(n,m.size()-1);
   return GetParam(msg,1);

   }

//---------------------------------------------------------------------------
vector<string> parse_msg(const string& msg, const string& format, int skip) {

   vector<string> rv;
   int i = skip;
   string::const_iterator ite = format.begin();
   string str;
   char b;
   while(ite != format.end()) {
      b = *ite;
      switch(b) {
         case 'b':
            rv.push_back(string(1,msg[i]));
            break;
         case 's':
            str = "";
            do {
               str += msg[i];
               ++i;
               } while(msg[i] != PARAMSEP);
            rv.push_back(str);
            break;
         default: WriteToLog(1,"unknown format");
         }
      ++i;
      ++ite;
      }
   return rv;
   }

//---------------------------------------------------------------------------
void AddLenPrefix(string& msg) {

   unsigned long len = msg.size();
   string l(4,'x');
   l[0] = (len & 0xFF000000) >> 24;
   l[1] = (len & 0x00FF0000) >> 16;
   l[2] = (len & 0x0000FF00) >> 8;
   l[3] = len & 0x000000FF;
   msg = l+msg;

   }

//---------------------------------------------------------------------------
long GetLenPrefix(const string& msg) {

   return (msg[0] << 24) + (msg[1] << 16) + (msg[2] << 8) + msg[3];

   }

namespace mnetmsg {

//------------------------------------------------------------------------------
base::base() : flags(0), type(0) {}
//------------------------------------------------------------------------------
base::base(const string& m) : msg(m) {
 
   // parse msg and init the dict
   flags = msg[0];
   type  = msg[1];
   const int len = msg.size();
   int s = 0;
   string key,val;
   for(int i=2; i<len; ++i) {
      if(s==0 && msg[i]=='=') s=1;
      else if(msg[i]==27)  {s=0;dict[key]=val;key=val="";}
      else if(s==0) key += msg[i];
      else if(s==1) val += msg[i];
      }
   if(s!=0) dict[key]=val;
   WriteToLog(3,string("base ctor: ")+log());
   // log
   /*mdict::iterator ite = dict.begin();
   while(ite!=dict.end()) {
      cout << ite->first << '=' << ite->second << endl;
      ++ite;  
      }*/
  
   }

//------------------------------------------------------------------------------
const string base::flog(const string& s) {
   
   string log = s;
   log.erase(0,2);
   for(int i=s.size()-1; i>=2; --i) {
      if(s[i]==PARAMSEP) log[i-2] = '/';
      else if(s[i]==SUBPARAMSEP) log[i-2] = '\\';
      else if(s[i]<32) {
         log.erase(i,1);
         log.insert(i,string("[")+MUtils::toStr((int)s[i])+"]");            
         }
      }
   return string("[f:")+MUtils::toStr((int)s[0])+"][t:"+MUtils::toStr((int)s[1])+"]"+log;
   
   }

//------------------------------------------------------------------------------
const string base::log() {
   
   return flog(str());

   }

//------------------------------------------------------------------------------
const string base::str() {

   ostringstream o;
   o << flags << type;
   mdict::iterator ite = dict.begin();
   while(ite!=dict.end()) {
      if(o.str().size()>2) o << PARAMSEP;
      o << ite->first << '=' << ite->second;
      ++ite;  
      }

   //string s = o.str();
   //WriteToLog(3,string("base::str(): ")+flog(s));
   //return s;
   return o.str();

   }

//------------------------------------------------------------------------------
const string base::list() {

   ostringstream o;
   o << flags << type;
   mlist::iterator ite = l.begin();
   mlist::iterator b = ite;
   while(ite!=l.end()) {
      if(o.str().size()>2 && ((*b).type!=1)) o << PARAMSEP;
      o << (*ite).value;
      b = ite;
      ++ite;
      }

   //string s = o.str();
   //WriteToLog(3,string("base::str(): ")+flog(s));
   //return s;
   return o.str();

   }


//------------------------------------------------------------------------------
void base::clear() {
   
   flags = type = 0;
   dict.clear();
   l.clear();
   
   }

//------------------------------------------------------------------------------
std::string& base::operator[](const std::string& p) {
   
   return dict[p]; // too simple
   
   // debug version:
   /*
   mdict::iterator i = dict.find(p);
   if(i==dict.end()) {
      WriteToLog(1,p+" not found in dict (may be normal)");
      return dict[p];
      }
   return i->second;
   */
   
   }

//------------------------------------------------------------------------------

} // namespace
