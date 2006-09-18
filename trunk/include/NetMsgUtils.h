#ifndef NetMsgUtilsH
#define NetMsgUtilsH

#include <string>
#include <map>
#include <vector>
#include <sstream>
//#include "MUtils.h"

const char PARAMSEP         = 27;
const char SUBPARAMSEP      = 28;

std::string GetParam(const std::string& m, int n);
int GetIntParam(const std::string& m, int n);
std::string GetParamFrom(const std::string& m, int n);
void AddLenPrefix(std::string& m);
long GetLenPrefix(const std::string& msg);
std::vector<std::string> parse_msg(const std::string& msg, const std::string& format, int skip=0);

namespace mnetmsg {

struct el {
   int type; // 0 = string, 1 = byte (no sep added)
   std::string value;
   };
typedef std::map<std::string,std::string> mdict;
typedef std::vector<el> mlist;


//---------------------------------------------------------------------------
/*** Base class for net messages */
class base {
public:

   base();
   base(const std::string& msg);
   void clear();
   std::string& operator[](const std::string& p);
   const std::string str();  // fomatted string ready to be sent based on dict
   const std::string list(); // fomatted string ready to be sent based on list
   const std::string log();  // fomatted string ready to be printed out
   void setType(char c) {type=c;}
   char getType() {return type;}
   void setHeader(const std::string& s) {flags=s[0]; type=s[1];}
   void add(int i) {
      std::ostringstream o;
      o << i;
      el e;
      e.type = 0;
      e.value = o.str();
      l.push_back(e);
      }
   void addByte(int i) {
      std::ostringstream o;
      o << char(i);
      el e;
      e.type = 1;
      e.value = o.str();
      l.push_back(e);
      }
   //void addSep() {addByte(PARAMSEP);}
   void add(const std::string& s) {
      el e;
      e.type = 0;
      e.value = s;
      l.push_back(e);
      }

protected:

   std::string msg;
   char flags, type;
   mdict dict;
   mlist l;

   //virtual void parse();
   virtual const std::string flog(const std::string& s);
   
   };

} // namespace

#endif
