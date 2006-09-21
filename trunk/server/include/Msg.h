//---------------------------------------------------------------------------
#ifndef MsgH
#define MsgH

#include "NetMsgUtils.h"

//---------------------------------------------------------------------------

/*** syslogin */
class syslogin : public mnetmsg::base {
public:
   std::string login, pwd, proto_ver, prog_ver;
   syslogin(const std::string& m) : mnetmsg::base(m) {}
protected:
   };
/*** syserror */
class syserror : public mnetmsg::base {
public:
   std::string msg;
   syserror(const std::string& m) : mnetmsg::base(m) {}
protected:
   };


#endif

