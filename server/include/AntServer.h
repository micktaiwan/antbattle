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
   void Remove(long id);
   void Clear() {WL.clear();}

private:
   MWL WL;
   };

//---------------------------------------------------------------------------
class MAntServer : public MPNL::MTCPServer {

   public:
      int NbAnt;
      MAntServer();
      virtual ~MAntServer();
      void SetMapSize(int w, int h);
      void SetMapObs(int x, int y);

      void Run(int port);
      void HTTPInfo(std::string& str); // return info on the server
      void SetHTTPPort(int p);
      void SetActionTimeout(int t) {ActionTimeout = t*1000;}

   private:
      TIME UpTime;
      TIME ActionTimeout;
      MClientStats ClientStats;
      MHTTPServer* HTTP;
      enum MService {SERVICE_CONN, SERVICE_CHAT, SERVICE_GAMEMSG};
      int      CurrentClientID; //  used for generating new ID
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
      void StopGame(long winner, long loser, int reason, const std::string& freetext);
      void SetMap();
      void BroadcastService(const MService& s, MPNL::MSocket* excluded, const std::string& str);
      void BroadcastToGUI(MPNL::MSocket* excluded, const std::string& msg);
      void SubscribeClient(const MService& s, MAntClient* c, int on);
      void SwitchPlayer();
      void AddError(MPNL::MSocket* s, MAntClient* c, const std::string& msg);
      void SendMap(MPNL::MSocket* excluded);
      inline MAntClient* OtherPlayer(MAntClient* c);
      void CheckTimeout();


      // Actions
      void Move(MPNL::MSocket* s, MAntClient* c, long id, int x, int y);
      void Attack(MPNL::MSocket* s, MAntClient* c, long id1, long id2);
   };

#endif

