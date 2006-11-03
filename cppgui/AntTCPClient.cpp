#pragma hdrstop
#include "AntTCPClient.h"

#pragma package(smart_init)

using namespace MPNL;
using namespace std;

extern void WriteToLog(int, const std::string&);

//---------------------------------------------------------------------------
void MAntTCPClient::OnDisconnection(MSocket* s) {

   // WriteToLog(2,"Disconnection");
   // when stoping socket thread, we can not write in the main thread
   

   }

//---------------------------------------------------------------------------
void MAntTCPClient::FormatSend(const string& msg) {

   string m = msg;
   replace(m.begin(), m.end(), '~', char(27));
   Send(m);

   }
//---------------------------------------------------------------------------

