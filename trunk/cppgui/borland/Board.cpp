#include <vcl.h>
#pragma hdrstop

#include <sstream>
#include "Board.h"
#include "MMap.h"
#include "AntClient.h"
#pragma package(smart_init)

extern void WriteToLog(int t, const std::string& msg);

//---------------------------------------------------------------------------
__fastcall MBoard::MBoard(TWinControl* o) : TPanel (o) {

   Parent   = o;
   Align    = alClient;
   Anchors <<  akBottom;
   PB       = new TPaintBox(this);
   PB->Parent  = this;
   PB->Align   = alClient;
   PB->OnPaint = OnPaint;
   PB->Canvas->Brush->Style = bsSolid;
   PB->Canvas->Pen->Color = clBlack;

   }

//---------------------------------------------------------------------------
__fastcall MBoard::~MBoard() {

   delete PB;

   }

//---------------------------------------------------------------------------
void __fastcall MBoard::OnPaint(System::TObject*) {

   TCanvas* c = PB->Canvas;
   c->Brush->Color = clWhite;
   c->FillRect(TRect(0,0,PB->Width,PB->Height));
   int w, h;
   Map->GetSize(w,h);
   int cw = PB->Width/w;
   int ch = PB->Height/h;
   if(cw<ch) ch = cw;
   else cw = ch;
   //c->Brush->Color = clGray;
   c->Pen->Color = clGray;
   for(int i=0;i <= w; ++i) {
      c->MoveTo(i*cw,0);
      c->LineTo(i*cw,h*ch);
      }
   for(int j=0;j <= h; ++j) {
      //c->FrameRect(TRect(i*cw,j*ch,i*cw+cw+1,j*ch+ch+1));
      c->MoveTo(0,j*ch);
      c->LineTo(w*cw,j*ch);
      }
   MMap::MMapIte ite = Map->Objects.begin();
   MAnt* ant;
   MResource* res;
   std::ostringstream s;
   while(ite!=Map->Objects.end()) {
      switch(ite->second->Type) {
         case 0: {
            ant = static_cast<MAnt*>(ite->second);
            if(!ant) throw("not an ant ?");
            if(ant->Life==0) goto next;
               //c->Brush->Color = clGray;
            else if(ant->ClientID==Player1)
               c->Brush->Color = clRed;
            else
               c->Brush->Color = clBlue;
            c->Rectangle(ant->Pos.X*cw+1,ant->Pos.Y*ch+1,ant->Pos.X*cw+cw,ant->Pos.Y*ch+ch);

            s.str("");
            s << ant->ClientID;
            c->TextOut(ant->Pos.X*cw+2,ant->Pos.Y*ch+2,s.str().c_str());

            //s.str("");
            //s << "disp: " << ant->ID << ": (" <<  ant->Pos.X << "," << ant->Pos.Y << ")\n";
            //WriteToLog(1,s.str());
            break;
            }
         case 1 : {
            res = static_cast<MResource*>(ite->second);
            if(!res) throw("not a res ?");
            c->Brush->Color = clBlack;
            c->Rectangle(res->Pos.X*cw+1,res->Pos.Y*ch+1,res->Pos.X*cw+cw,res->Pos.Y*ch+ch);
            break;
            }
         } // switch
next:
      ++ite;
      } // while
   }

//---------------------------------------------------------------------------
void MBoard::SetPlayers(int id1, int id2) {

   Player1 = id1;
   Player2 = id2;

   }

