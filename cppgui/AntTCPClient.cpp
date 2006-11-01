#pragma hdrstop
#include "AntTCPClient.h"

#pragma package(smart_init)

using namespace MPNL;
using namespace std;

//---------------------------------------------------------------------------
void MAntTCPClient::FormatSend(const string& msg) {

   string m = msg;
   replace(m.begin(), m.end(), '~', char(27));
   Send(m);

   }
