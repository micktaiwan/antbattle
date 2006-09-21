//---------------------------------------------------------------------------
#ifndef AntServerH
#define AntServerH

#include <vector>
#include "MPNLBase.h"
#include "Msg.h"
#include "MStats.h"

class MAntClient;
class MMap;
class MHTTPServer;

//---------------------------------------------------------------------------
class MWList {

public:
   typedef std::vector<MAntClient*> MWL;
   
   MWList() {}
   ~MWList() {}

   void Add(MAntClient* c);
   const MWL& GetWL() {return WL;}
   MAntClient* GetClient(int index) {return WL[index];}
   void Remove(unsigned long id);
   void Clear() {WL.clear();}

private:
   MWL WL;
   };

//---------------------------------------------------------------------------
class MAntServer : public MPNL::MTCPServer {

   public:
      MAntServer();
      virtual ~MAntServer();

      void Run(int port);
      void HTTPInfo(std::string& str); // return info on the server
      void SetHTTPPort(int p);

   private:
      TIME UpTime;
      MClientStats ClientStats;
      MHTTPServer* HTTP;
      enum MService {SERVICE_CONN, SERVICE_CHAT, SERVICE_GAMEMSG};
      int      CurrentClientID;
      bool     GameInProgress;
      MWList   WL;
      MWList   DisconnectList; // to delete clients in the main thread
      MMap*    Map;
      boost::mutex ParseMutex;
      int CurrentPlayerWLPos;
      MAntClient* Player1, *Player2;

      bool OnConnection(MPNL::MSocket* s);
      void OnDisconnection(MPNL::MSocket* s);
      void Parse(MPNL::MSocket* s);
      inline MAntClient* GetData(MPNL::MSocket* s) {return static_cast<MAntClient*>(s->Data);}
      void AllDataString(mnetmsg::base& m);
      void StartGame();
      void StopGame(unsigned long winner, unsigned long loser, int reason, const std::string& freetext);
      void SetMap();
      void BroadcastService(const MService& s, MPNL::MSocket* excluded, const std::string& str);
      void BroadcastToGUI(MPNL::MSocket* excluded, const std::string& msg);
      void SubscribeClient(const MService& s, MAntClient* c, int on);
      void SwitchPlayer();
      void AddError(MAntClient* c);
      void SendMap(MPNL::MSocket* excluded);
      // Actions
      void Move(MPNL::MSocket* s, MAntClient* c, unsigned long id, int x, int y);
      void Attack(MPNL::MSocket* s, MAntClient* c, unsigned long id1, unsigned long id2);
   };

#endif

