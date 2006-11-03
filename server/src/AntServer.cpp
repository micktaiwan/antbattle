//---------------------------------------------------------------------------
#include <stdlib.h>
#include <string>
#include "AntServer.h"
#include "AntClient.h"
#include "MMap.h"
#include "HTTPServer.h"

// TODO 3: passer les ClientID en long


//---------------------------------------------------------------------------
#ifdef WIN32
#pragma package(smart_init)
#endif
using namespace std;
using namespace mnetmsg;

extern void WriteToLog(int, const std::string&);
extern bool SigInt;
extern string ProgramName;
const string ProtocolVersion = "0.6";

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
void MWList::Add(MAntClient* c) {

   Remove(c->ClientID); // to avoid duplicates
   WL.push_back(c);

   }

//---------------------------------------------------------------------------
void MWList::Remove(long id) {
// does not delete the client

   MWL::iterator ite = WL.begin();
   while(ite!=WL.end()) {
      if((*ite)->ClientID == id) {WL.erase(ite);return;}
      ++ite;
      }

   }

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
MAntServer::MAntServer() : MPNL::MTCPServer(), NbAnt(10), CurrentClientID(0), GameInProgress(0), Map(new MMap()) {

   HTTP = new MHTTPServer();
   HTTP->Port = 8080;
#ifdef WIN32
   HTTP->SetCallback(HTTPInfo);
#else
   HTTP->SetCallback(&MAntServer::HTTPInfo);
#endif
   GETTIME(UpTime);

   }

//---------------------------------------------------------------------------
MAntServer::~MAntServer() {

   delete Map;
   HTTP->Stop();
   delete HTTP;

   }

//---------------------------------------------------------------------------
void MAntServer::Run(int port) {

   WriteToLog(2,string("Running on port ") + MUtils::int2string(port));
   SetPrefixLen(2);
   Port = port;
   if(!Listen()) {
      WriteToLog(1,GetLastError());
      return;
      }

   if(!HTTP->Listen())
      WriteToLog(1,string("HTTP: Bind error for port ") + MUtils::int2string(HTTP->Port));

   MPNL::MSocket* s;
   while(!SigInt) {

      // delete disconnected clients
      MWList::MWL wl = DisconnectList.GetWL();
      if(wl.size()>0) {
         MWList::MWL::iterator ite = wl.begin();
         while(ite!=wl.end()) {
            // find the socket to nullify the Data
            // Pas beau !!! ****
            MPNL::MClientList* l = LockClients();
            MPNL::MClientList::iterator cite = l->begin();
            MAntClient* c;
            MPNL::MSocket* s;
            while(cite != l->end()) {
               s = cite->Socket;
               c = GetData(s);
               if(c == (*ite)) {
                  s->Data = NULL;
                  break;
                  }
               ++cite;
               }
            UnlockClients();
            // ****
            delete (*ite); // DONE 1: on delete un client qui est reference ensuite dans BroadcastToGUI
            ++ite;
            }
         DisconnectList.Clear();
         }

      // Start Games
      if(!GameInProgress && WL.GetWL().size()>=2)
         StartGame();

      while(Read(s)) {
         Parse(s);
         }
      SLEEP(20);

      // TODO 1: check the timeout

      } // while
   WriteToLog(2,string("Shutting down..."));

   }

//---------------------------------------------------------------------------
bool MAntServer::OnConnection(MPNL::MSocket* s) {

   boost::mutex::scoped_lock lock(ParseMutex);

   WriteToLog(2,string("New connection from ")+s->PeerIP);
   MAntClient* c = new MAntClient(); // TODO 1: jamais delete si Ctrl-C
   c->IP = s->PeerIP;
   c->ClientID = 0;
/*
   c->Type = -1;
   c->Program = "NL";
   c->Version = "NL";
   c->FreeText = "Not loggued";
*/
   s->Data = c;
   return true;

   }

//---------------------------------------------------------------------------
void MAntServer::OnDisconnection(MPNL::MSocket* s) {

   boost::mutex::scoped_lock lock(ParseMutex);

   MAntClient* c = GetData(s);
   ostringstream msg;
   msg  << "Client Disconnection: ID=" << c->ClientID
      << " (Logged=" << c->Logged << "), ip=" << s->PeerIP  << ", Nb=" << NbClients();
   WriteToLog(2,msg.str());

   if(c->Logged) { // broadcast a message only if client is logged
      long id = c->ClientID;
      WL.Remove(id);
      if(c->Type==0) {
         // if the client was playing, he loses
         if(c->Playing) {
            int loser, winner;
            if(id == Player1->ClientID) {
               loser  = Player1->ClientID;
               winner = Player2->ClientID;
               }
            else {
               winner = Player1->ClientID;
               loser  = Player2->ClientID;
               }
            StopGame(winner,loser,3, "Disconnection"); // will be removed from WL
            } // GameInProgress
         } // Type == 0
      base mm;
      mm.setHeader("Ad");
      mm.add(id);
      BroadcastService(SERVICE_CONN, s, mm.list());
      } // Logged

   DisconnectList.Add(c);

   }

//---------------------------------------------------------------------------
void MAntServer::Parse(MPNL::MSocket* s) {

   boost::mutex::scoped_lock lock(ParseMutex);

   string msg, tmp;
   stringstream ss;
   base mm;
   vector<string> v;
   int i;

   s->Read(msg);
   MAntClient* c = GetData(s);
   WriteToLog(3,string(   "[")+c->IP+"]: "+msg);
   switch(msg[0]) {
      case 'A':
         switch(msg[1]) {
            case 'a': // Login
               tmp = GetParam(msg,2);
               WriteToLog(2, string("Received login: ")+tmp);
               ss << GetParam(msg,1);
               ss >> c->Type;
               c->Program = tmp;
               c->Version = GetParam(msg,3);
               c->FreeText = GetParam(msg,4);
               c->Logged = true;
               c->ClientID = CurrentClientID;
               // we send a welcome message with some infos
               mm.clear();
               mm.setHeader("Aa");
               mm.add(CurrentClientID);
               mm.add(ProtocolVersion);
               s->Send(mm.list());
               ++CurrentClientID;
               // Broadcast connection
               mm.clear();
               mm.setHeader("Ac");
               c->DataString(mm);
               BroadcastService(SERVICE_CONN,s,mm.list());
               // send the map
               if(GameInProgress && c->Type == 1) {
                  mm.clear();
                  mm.setHeader("Ec");
                  Map->DataString(mm);
                  s->Send(mm.list());
                  }
               break;
            case 'b':  // Send clients list
               mm.clear();
               mm.setHeader("Ab");
               AllDataString(mm);
               s->Send(mm.list());
               break;
            case 'c': // subscription to clients conn/discon
               SubscribeClient(SERVICE_CONN, c, GetIntParam(msg,1));
               break;
            case 'f': // subscription to game msg
               SubscribeClient(SERVICE_GAMEMSG, c, GetIntParam(msg,1));
               if(GameInProgress) { // send the map
                  mm.clear();
                  mm.setHeader("Ec");
                  Map->DataString(mm);
                  s->Send(mm.list());
                  }
               break;
            default:
               WriteToLog(1, string("not implemented: ")+msg[1]);
            }
         break;
      case 'B': // Game
         switch(msg[1]) {
            case 'b': // Inscription
               i = GetIntParam(msg,1);
               if(!i) {
                  WL.Remove(c->ClientID);
                  WriteToLog(2, string("Game withdraw"));
                  break;
                  }
               WriteToLog(2, string("Game inscription"));
               if(!c->Logged || c->Type!=0) {
                  mm.clear();
                  mm.setHeader("Ba");
                  mm.add("2");
                  mm.add("Only logged clients with type 0 can play");
                  s->Send(mm.list());
                  break;
                  }
               WL.Add(c);
               break;
            default:
               WriteToLog(1, string("not implemented: ")+msg[1]);
            }
         break;
      case 'C': // Action
         if(!GameInProgress || (c!=Player1 && c!=Player2)) {
            mm.clear();
            mm.setHeader("Ba");
            mm.add("1");
            mm.add("Your are not playing a game");
            s->Send(mm.list());
            break;
            }
         switch(msg[1]) {
            case 'a': // End of turn
               // TODO 3: process Freetext better
               WriteToLog(3, string("End of turn ")+GetParam(msg,1));
               SwitchPlayer();
               break;
            case 'b': // Move (ID/X_Y_)
               v = parse_msg(msg,"sbb",2);
               ss << v[0];
               ss >> i;
               Move(s,c,i,v[1][0],v[2][0]);
               break;
            case 'c': // Attack (ID/ID)
               Attack(s,c,GetIntParam(msg,1),GetIntParam(msg,2));
               break;
            default:
               WriteToLog(1, string("not implemented: ")+msg[1]);
            }
         break;
      case 'D': // Chat
         switch(msg[1]) {
            case 'a': // Msg from client
               if(!c->Logged) {
                  mm.clear();
                  mm.setHeader("Ba");
                  mm.add("2");
                  mm.add("Chat reserved to logged clients");
                  s->Send(mm.list());
                  break;
                  }
               tmp = GetParam(msg,1);
               WriteToLog(3, string("@")+c->Program+": "+tmp);
               // Broadcast
               mm.clear();
               mm.setHeader("Da");
               mm.add(c->ClientID);
               mm.add(tmp);
               BroadcastService(SERVICE_CHAT,NULL,mm.list());
               break;
            case 'b': // subscription
               SubscribeClient(SERVICE_CHAT,c, GetIntParam(msg,1));
               break;
            default:
               WriteToLog(1, string("not implemented: ")+msg[1]);
            }
         break;
      default:
         WriteToLog(1, string("not implemented: ")+msg[0]);
      }

   }

//---------------------------------------------------------------------------
void MAntServer::AllDataString(base& m) {

   MPNL::MClientList* l = LockClients();
   MPNL::MClientList::iterator ite = l->begin();
   MAntClient* c;
   while(ite != l->end()) {
      c = GetData(ite->Socket);
      if(c->Logged) c->DataString(m);
      ++ite;
      }
   UnlockClients();

   }

//---------------------------------------------------------------------------
void MAntServer::StartGame() {

   if(GameInProgress || WL.GetWL().size()<2)
      throw runtime_error("Can not startgame. Game in progress or not enough client.");

   GameInProgress = true;
   Player1 = WL.GetClient(0);
   Player2 = WL.GetClient(1);
   Player1->Playing = true;
   Player2->Playing = true;

   // Broadcast the game
   WriteToLog(2,string("=== New Game: ")+Player1->Program+" vs "+Player2->Program);
   base mm;
   mm.setHeader("Bb");
   mm.add(Player1->ClientID);
   mm.add(Player2->ClientID);
   BroadcastToGUI(NULL,mm.list()); // DONE 2: broadcast seulement aux clients interesses

   // Set the map
   SetMap();

   // Send the map
   SendMap(NULL);

   CurrentPlayerWLPos = 1;
   SwitchPlayer();

   }

//---------------------------------------------------------------------------
void MAntServer::StopGame(long winner, long loser, int reason, const string& freetext) {

   WriteToLog(2,string("=== Stopping game: ")+freetext);
   Map->ClearAnt();// we must clear the map now,
   // because if the playing client disconnects
   // the next time a client plays the map will try
   // to reset a map accessing deleted ant
   GameInProgress = false;
   WL.Remove(loser);
   Player1->Playing = false;
   Player2->Playing = false;
   base mm;
   mm.setHeader("Be");
   mm.add(winner);
   mm.add(loser);
   mm.add(reason);
   mm.add(freetext);
   BroadcastMsg(NULL,mm.list());
   string str1  = Player1->Program+" "+Player1->Version;
   string str2  = Player2->Program+" "+Player2->Version;
   if(Player1->ClientID == winner) {
      ClientStats.SafeGet(str1)->Win++;
      ClientStats.SafeGet(str2)->Loss++;
      }
   else {
      ClientStats.SafeGet(str2)->Win++;
      ClientStats.SafeGet(str1)->Loss++;
      }

   }

//---------------------------------------------------------------------------
void MAntServer::SetMap() {

   Map->ClearAnt(); // the resources are set once for all
   //reading the server config file, so we keep them
   // (but we could read them here too)
   int w,h;
   Map->GetSize(w,h);
   MAntClient* c;
   int xs[2] = {0,w-1};
   int ys[2] = {0,h-1};
   MAnt* a;
   for(int i=0; i < 2; ++i) {
      c = WL.GetClient(i);
      c->Colony.Clear();
      for(int j=0; j < NbAnt; ++j) {
         a = new MAnt();
         a->Life = 25; // TODO 2: configurable
         a->ActionPoints = 8; // TODO 2: configurable
         a->ClientID = c->ClientID;
         a->Pos.X = xs[i];
         a->Pos.Y = ys[i];
         Map->AddObject(a,true);
         c->Colony.AddAnt(a); // !!!! must come after AddObject as this function add the ID
         }
      }
   }

//---------------------------------------------------------------------------
void MAntServer::SetMapSize(int w, int h) {
   Map->SetSize(w,h);
   }
//---------------------------------------------------------------------------
void MAntServer::SetMapObs(int x, int y) {
   Map->SetObs(x,y);
   }

//---------------------------------------------------------------------------
void MAntServer::BroadcastService(const MService& s, MPNL::MSocket* excluded, const string& msg) {

   MAntClient* c;
   MPNL::MClientList* cl = LockClients();
   MPNL::MClientList::iterator ite = cl->begin();
   while(ite != cl->end()) {
      if(ite->Socket != excluded) {
         c = GetData(ite->Socket);
         if(c->Services[s]==1) ite->Socket->Send(msg);
         }
      ++ite;
      }
   UnlockClients();

   }

//---------------------------------------------------------------------------
void MAntServer::SubscribeClient(const MService& s, MAntClient* c, int value) {

   c->Services[s] = value;

   }

//---------------------------------------------------------------------------
void MAntServer::SwitchPlayer() {

   if(!GameInProgress) return;
   
   CurrentPlayerWLPos = !CurrentPlayerWLPos;
   MAntClient* c = WL.GetClient(CurrentPlayerWLPos);
   c->ErrorCount = 0;
   c->Colony.ResetActionPoints();

   // Send the signal
   base mm;
   mm.setHeader("Bd");
   mm.add(c->ClientID);
   BroadcastToGUI(NULL,mm.list()); // DONE 2: broadcast seulement aux clients interesses

   }

//---------------------------------------------------------------------------
void MAntServer::Move(MPNL::MSocket* s, MAntClient* c, long id, int x, int y) {

   ostringstream o;
   o <<  "Move: " << id << " x=" << x << " y=" << y;
   WriteToLog(3,o.str());

   // Verify that the object is real
   MAnt* ant = static_cast<MAnt*>(Map->GetObjectByID(id));
   if(ant == NULL) {
      AddError(s,c,"Move: the object does not exist");
      return;
      }

   // Is there an obstacle at the target case (TODO: pathfinding)
   MMap::MObjList l = Map->GetObjects(x,y);
   if(l.size()) {
      AddError(s,c,"Move: an obstacle is on the target case");
      return;
      }

   int nbcases = abs(ant->Pos.X-x) + abs(ant->Pos.Y-y);
   // not going too far ?
   if(nbcases > ant->Speed) {
      AddError(s,c,"Move: going too far for this ant's speed");
      return;
      }

   // substract action points
   if((ant->ActionPoints - nbcases) < 0) {
      AddError(s,c,"Move: not enough action points");
      return;
      }

   // verify that the ant is ours !!!
   if(ant->ClientID != c->ClientID) {
      AddError(s,c,"Move: trying to move some opponent ant");
      return;
      }

   // remove one point by case
   ant->ActionPoints -= nbcases;
   ant->Pos.X = x;
   ant->Pos.Y = y;

   // Broadcast the move
   base mm;
   mm.setHeader("Cb");
   mm.add(id);
   mm.addByte(x);
   mm.addByte(y);
   BroadcastToGUI(NULL, mm.list());

   }

//---------------------------------------------------------------------------
void MAntServer::Attack(MPNL::MSocket* s, MAntClient* c, long id1, long id2) {

   ostringstream o;
   o <<  "Attack: " << id1 << " vs " << id2;
   WriteToLog(3,o.str());

   // Verify that the object is real
   MAnt* ant1 = static_cast<MAnt*>(Map->GetObjectByID(id1));
   MAnt* ant2 = static_cast<MAnt*>(Map->GetObjectByID(id2));
   if(ant1 == NULL || ant2 == NULL) {
      o.str("");
      o << "Attack " << id1 << " vs " << id2 << " : the ant does not exist";
      AddError(s,c,o.str());
      return;
      }

   // not attacking too far ?
   if(abs(ant1->Pos.X-ant2->Pos.X) + abs(ant1->Pos.Y-ant2->Pos.Y) > 1) {
      AddError(s,c,"Attack: you are too far away");
      return;
      }

   // substract action points
   if((ant1->ActionPoints - 5) < 0) { // TODO 2: configurable
      AddError(s,c,"Attack: not enough action points");
      return;
      }

   // verify that the ant is ours
   if(ant1->ClientID != c->ClientID) {
      AddError(s,c,"Attack: trying to use some opponent ant");
      return;
      }

   ant1->ActionPoints -= 5;
   ant2->Life -= 5;
   if(ant2->Life <= 0) ant2->Life = 0;

   // Broadcast the move
   base mm;
   mm.setHeader("Cc");
   mm.add(id1);
   mm.add(id2);
   mm.add(ant2->Life);
   BroadcastToGUI(NULL, mm.list());

   if(ant2->Life == 0) { // remove ant from map
      WriteToLog(3,"Ant dead");
      Map->RemoveObject(ant2);
      MAntClient* e;
      if(ant2->ClientID == Player1->ClientID) e = Player1;
      else e = Player2;
      int ant2cid = ant2->ClientID;
      e->Colony.DeleteAnt(ant2->ID);
      //o.str("");
      //o << "Colony.size : " << c->Colony.Size();
      //WriteToLog(3,o.str());
      if(e->Colony.Size()==0)
         StopGame(ant1->ClientID,ant2cid,0, "Victory !");
      }

   }


//---------------------------------------------------------------------------
void MAntServer::AddError(MPNL::MSocket* s, MAntClient* c, const string& msg) {

   c->ErrorCount = c->ErrorCount + 1;
   WriteToLog(2,string("Client error: ")+msg+", total: "+MUtils::toStr(c->ErrorCount));
   base mm;
   mm.setHeader("Ba");
   mm.add("1");
   mm.add(msg);
   s->Send(mm.list());
   if(c->ErrorCount < 3) return;

   long i1 = Player1->ClientID;
   long i2 = Player2->ClientID;
   int loser, winner;
   if(c->ClientID == i1) {
      loser  = i1;
      winner = i2;
      }
   else {
      winner = i1;
      loser  = i2;
      }
   StopGame(winner,loser,2, "Too many errors");

   }

//---------------------------------------------------------------------------
void MAntServer::BroadcastToGUI(MPNL::MSocket* excluded, const string& msg) {

   MPNL::MClientList* l = LockClients();
   MPNL::MClientList::iterator ite = l->begin();
   MAntClient* c;
   MPNL::MSocket* s;
   while(ite != l->end()) {
      s = ite->Socket;
      c = GetData(s);
      if(c && c->Logged && s != excluded) { // DONE 1: access to freed memory
         if(c->Type==1 || c->Services[SERVICE_GAMEMSG]==1 || c->Playing)
            s->Send(msg);
         }
      ++ite;
      }
   UnlockClients();

   }

//---------------------------------------------------------------------------
void MAntServer::SendMap(MPNL::MSocket* excluded) {

   base mm;
   mm.setHeader("Ec");
   Map->DataString(mm);
   BroadcastToGUI(excluded,mm.list()); // broadcast seulement aux clients interesses

   }

//---------------------------------------------------------------------------
void MAntServer::HTTPInfo(std::string& str) {

   int nb = NbClients();
   ostringstream s;
   s << "<b>" << ProgramName << "</b><br/>";
   s << "Please visit <a href=\"http://faivrem.googlepages.com/antbattle\">http://faivrem.googlepages.com/antbattle</a> for more information<br/><br/>";
   s << "Time: " << MUtils::MyNow(1) << "<br/>";
   unsigned int d,h,m;
   MUtils::GetDuration(UpTime,d,h,m);
   s << "Uptime: ";
   if(d) s << d << " days ";
   if(d || h) s << h << " hours ";
   s << m << " minutes";
   s << "<br/>";
   s << "Current connections: " << nb << "<br/>";
   s << "Game in progress: " << (GameInProgress?"yes":"no") << "<br/>";
   s << "<br/>";
   if(nb) {
      s << "<b>Connected clients</b><br/>";
      s << "<table><tr style=\"font-weight:bold;\"><td>Name</td><td>Freetext</td><td>Type</td><td>Playing</td></tr>";
      MPNL::MClientList* l = LockClients();
      if(l) {
         MPNL::MClientList::iterator ite = l->begin();
         MAntClient* c;
         while(ite != l->end()) {
            c = GetData(ite->Socket);
            if(c) {
               if(c->Logged) {
                  s << "<tr><td><b>" << c->Program << "</b> " << c->Version << "</td><td>" << c->FreeText;
                  s << "</td><td style=\"text-align:center;\">" << (c->Type?"GUI":"AI");
                  s << "</td><td style=\"text-align:center;\">" << (c->Playing?"yes":"no");
                  s << "</td></tr>";
                  }
               else s << "<tr><td>not logged</td><td></td><td></td><td></td></tr>";
               }
            ++ite;
            }
         }
      UnlockClients();
      s << "</table><br/><br/>";
      }
      
   if(ClientStats.List.size()) {
      s << "<b>Stats</b><br/>";
      s << "<table><tr style=\"font-weight:bold;\"><td>Name</td><td>Win</td><td>Loss</td><td>Last connection</td></tr>";
      MClientStats::MList::iterator ite = ClientStats.List.begin();
      while(ite != ClientStats.List.end()) {
         s << "<tr><td><b>" << (*ite)->Name << "</b></td>";
         s << "<td style=\"text-align:center;\">" << (*ite)->Win << "</td>";
         s << "<td style=\"text-align:center;\">" << (*ite)->Loss << "</td>";
         s << "<td style=\"text-align:center;\">" << (*ite)->LastConn << "</td>";
         s << "</tr>";
         ++ite;
         }
      s << "</table>";
      }
      
   str = s.str();

   }

//---------------------------------------------------------------------------
void MAntServer::SetHTTPPort(int p) {

   HTTP->Port = p;
   // Listen is not called so if you want to set a port set ip before calling Run()

   }
