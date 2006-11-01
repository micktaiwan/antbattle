//---------------------------------------------------------------------------
#ifndef mainH
#define mainH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <Buttons.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
   TPageControl *PageControl1;
   TTabSheet *TSGUI;
   TTabSheet *TabSheet2;
   TMemo *Memo1;
   TTimer *Timer1;
   TPanel *Panel1;
   TEdit *Edit2;
   TEdit *Edit3;
   TBitBtn *BtnConnect;
   TLabel *Label1;
   TLabel *Label2;
   void __fastcall FormCreate(TObject *Sender);
   void __fastcall FormDestroy(TObject *Sender);
   void __fastcall Timer1Timer(TObject *Sender);
   void __fastcall BtnConnectClick(TObject *Sender);
private:	// User declarations
   MBoard* Board;
   MAntTCPClient* TCP;
   MAntClientList* Clients;
   MMap* Map;

   void SetupMap(const std::string& msg);
public:		// User declarations
   __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif

