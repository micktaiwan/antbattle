#ifndef AntTCPClientH
#define AntTCPClientH

#include "MPNLBase.h"
//class MAntClientList;

//---------------------------------------------------------------------------
class MAntTCPClient : public MPNL::MTCPClient  {

public:
  MAntTCPClient() {SetPrefixLen(2);}
  virtual ~MAntTCPClient() {}

  void FormatSend(const std::string& msg);
  virtual void   OnDisconnection(MPNL::MSocket* s);
  //void SetClients(MAntClientList* c) {Clients = c;}
  
private:
  //MAntClientList* Clients;
};


#endif

