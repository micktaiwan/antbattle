//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include <string>
#include <sstream>
#include "AntClient.h"
#include "AntTCPClient.h"
#include "Board.h"
#include "MMap.h"
#include "main.h"
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
using namespace std;

//---------------------------------------------------------------------------
void WriteToLog(int t, const string& msg) {

   if(t <= 3) Form1->Memo1->Lines->Add(msg.c_str());

   }

//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
   : TForm(Owner) {}

//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender) {

   WindowState = wsMaximized;
   
   Clients = new MAntClientList();

   Board = new MBoard(Panel1);
   Board->SetClients(Clients);
   Map = new MMap();
   Board->SetMap(Map);

   TCP = new MAntTCPClient();

   }

//---------------------------------------------------------------------------
void __fastcall TForm1::FormDestroy(TObject *Sender) {

   delete TCP;
   delete Board;
   delete Clients;
   delete Map;

   }

//---------------------------------------------------------------------------
void __fastcall TForm1::Timer1Timer(TObject *) {

   // TODO 1: check connection and reconnect if needed
   string msg;
   while(TCP->Read(msg)) {
      WriteToLog(3,msg);
      switch(msg[0]) {
         case 'A':
            switch(msg[1]) {
               case 'a':
                  WriteToLog(3,string("Receiving ID"));
                  break;
               case 'b':
                  WriteToLog(3,string("Receiving clients list"));
                  break;
               case 'c':
                  WriteToLog(3,string("Connection of client"));
                  break;
               case 'd':
                  WriteToLog(3,string("Disconnection of client"));
                  break;
               default:
                  ;//WriteToLog(1,string("Unknown msg type: ")+msg[1]);
               }
            break;
         case 'B':
            switch(msg[1]) {
               case 'b':
                  WriteToLog(2,string("Game Start"));
                  Board->SetPlayers(GetIntParam(msg,1),GetIntParam(msg,2));
                  break;
               case 'd':
                  WriteToLog(3,string("Turn"));
                  Board->OnPaint(NULL);
                  break;
               case 'e':
                  WriteToLog(2,string("Game end"));
                  Board->OnPaint(NULL);
                  break;
               default:
                  ;//WriteToLog(1,string("Unknown msg type: ")+msg[1]);
               }
            break;
         case 'C':
            switch(msg[1]) {
               case 'b': {
                  WriteToLog(3,string("Move"));
                  vector<string> rv = parse_msg(msg,"sbb",2);
                  stringstream s;
                  int i;
                  s << rv[0];
                  s >> i;
                  MAnt* ant  = static_cast<MAnt*>(Map->GetObjectByID(i));
                  if(ant!=NULL) {
                     ant->Pos.X = rv[1][0];
                     ant->Pos.Y = rv[2][0];
                     }
                  else WriteToLog(1,string("Error: object not an ant"));
                  }
                  break;
               case 'c': {
                  WriteToLog(3,string("Attack"));
                  int id   = GetIntParam(msg,2);
                  int life = GetIntParam(msg,3);
                  MAnt* ant  = static_cast<MAnt*>(Map->GetObjectByID(id));
                  if(ant!=NULL) ant->Life = life;
                  else WriteToLog(1,string("Ant not found"));
                  }
                  break;
               default:
                  ;//WriteToLog(1,string("Unknown msg type: ")+msg[1]);
               }
            break;
         case 'E':
            switch(msg[1]) {
               case 'c':
                  WriteToLog(3,string("Map"));
                  SetupMap(msg);
                  break;
               default:
                  ;//WriteToLog(1,string("Unknown msg type: ")+msg[1]);
               }
            break;
         default:;
            //WriteToLog(1,string("Unknown msg type: ")+msg[0]);
         }
      }

   }
//---------------------------------------------------------------------------
void TForm1::SetupMap(const string& msg) {

   //setup map and Colony info
   // is not in Map because we need the info to be stored elsewhere too
   // so this function fills the Map object and other Colony properties
   stringstream s;
   Map->SetSize(msg[2],msg[3]);

   //Allies.Clear();
   int i = 4;
   int x,y, type_fourmi, life;
   char type;
   string client_id, object_id;
   MAnt* ant;
   while(i < msg.size()) {
      object_id = GetParamFrom(msg,i);
      i += object_id.size()+1;
      x = msg[i++];
      y = msg[i++];
      type = msg[i++];
      if(type==0) {
         client_id = GetParamFrom(msg,i);
         i += client_id.size()+1;
         type_fourmi = msg[i++];
         life = msg[i++];
         if(type_fourmi==0) ant = new MAnt();
         else {
            WriteToLog(1,"Ant type not implemented");
            return;
            }
         ant->Pos.X = x;
         ant->Pos.Y = y;
         ant->Life = life;
         s.clear();
         s << client_id;
         s >> ant->ClientID;
         s.clear();
         s << object_id;
         s >> ant->ID;
         Map->AddObject(ant);
         // TODO 2: gerer les colonies
         }// type == 0
      else if(type==1) { // resource
         MResource* res = new MResource();
         s.clear();
         s << object_id;
         s >> res->ID;
         res->Pos.X = x;
         res->Pos.Y = y;
         res->RType = msg[i++];
         Map->AddObject(res);
         }
      else
         WriteToLog(1,"Object type not implemented");
      } // while object
   }

//---------------------------------------------------------------------------
void __fastcall TForm1::BtnConnectClick(TObject *Sender) {

   TCP->Host = Edit2->Text.c_str();
   TCP->Port = Edit3->Text.ToInt();
   //TCP->Host = "82.238.147.130";
   //TCP->Port = 80;
   //TCP->SetClients(Clients);
   TCP->Disconnect();
   if(!TCP->Connect())
      WriteToLog(1,"Error: could not connect");
   else {
      WriteToLog(1,"Connected");
      TCP->FormatSend("Aa1~Ant Battle Viewer~0.1~http://faivrem.googlepages.com/antbattle"); // login
      TCP->Send("Ab");  // client list
      TCP->Send("Ac1"); // connections
      TCP->Send("Db1"); // chats
      }

   }
//---------------------------------------------------------------------------

