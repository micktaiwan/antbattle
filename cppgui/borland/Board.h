//---------------------------------------------------------------------------
#ifndef BoardH
#define BoardH
//---------------------------------------------------------------------------
class MAntClientList;
class MMap;

class MBoard : public TPanel {
public:
   __fastcall MBoard(TWinControl* o);
   virtual __fastcall ~MBoard();

   TPaintBox* PB;
   void __fastcall OnPaint(System::TObject*);

   //int BWidth, BHeight;
   void SetClients(MAntClientList* c) {Clients = c;}
   void SetMap(MMap* m) {Map = m;}
   void SetPlayers(int id1, int id2);

private:
   int Player1, Player2;
   MAntClientList* Clients;
   MMap* Map;

};


#endif

