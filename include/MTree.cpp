// TODO :
// save feature (save tree as text)
// convert to TTreeView

#include <vcl.h>
#pragma hdrstop

#include "MGraphic.h"
#include "AnsiStringPlus.h"
#include "MTree.h"

#pragma package(smart_init)

int gAbsS; // canvas absolute abscissa shifting
int gOrdS; // canvas absolute ordinate shifting
int gAbs;  // Current MTreeNode abscissa
int gOrd;  // Current MTreeNode ordinate
int gMarginX = 50;
int gMarginY = 50;
int gWidth;
int gHeight;
bool gAltern;
MCallBackVoidP gDeleteNodeDataCB;

int __fastcall SortCompare(void* item1, void* item2) {

   return 0;

   }



// ------------------------------ MTreeNodeList -----------------------------


/*------------------------------*/
/* MTreeNodeList::MTreeNodeList */
/*------------------------------*/

__fastcall MTreeNodeList::MTreeNodeList() {

   Owner = NULL;

   }

/*-------------------------------*/
/* MTreeNodeList::~MTreeNodeList */
/*-------------------------------*/

__fastcall MTreeNodeList::~MTreeNodeList() {

   Clear();

   }

/*----------------------*/
/* MTreeNodeList::Clear */
/*----------------------*/

void __fastcall MTreeNodeList::Clear(void) {

   for(int i=0; i < Count; i++)
      delete static_cast<MTreeNode*>(Items[i]);
   TList::Clear();

   }

/*-------------------------*/
/* MTreeNodeList::AddFirst */
/*-------------------------*/

void __fastcall MTreeNodeList::AddFirst(MTreeNode* node) {

   TList::Insert(0,node);

   }

/*--------------------*/
/* MTreeNodeList::Add */
/*--------------------*/

void __fastcall MTreeNodeList::Add(MTreeNode* node) {

   TList::Add(node);

   }

/*--------------------*/
/* MTreeNodeList::Add */
/*--------------------*/

MTreeNode* __fastcall MTreeNodeList::Add(MTreeNode* parent, void* data) {

   MTreeNode* n = new MTreeNode();
   n->Tree = Tree;
   n->Parent = parent;
   n->Data = data;
   TList::Add(n);
   return(n);

   }

/*--------------------*/
/* MTreeNodeList::Add */
/*--------------------*/

MTreeNode* __fastcall MTreeNodeList::Add(void* data) {

   MTreeNode* n = new MTreeNode();
   n->Tree = Tree;
   n->Parent = NULL;
   n->Data = data;
   TList::Add(n);
   return(n);

   }


/*---------------------------*/
/* MTreeNodeList::DeleteNode */
/*---------------------------*/

void __fastcall MTreeNodeList::DeleteNode(MTreeNode* node) {

   int i = GetNodeIndex(node);
   delete static_cast<MTreeNode*>(Items[i]);
   Delete(i);
   
   }


/*-----------------------------*/
/* MTreeNodeList::GetNodeIndex */
/*-----------------------------*/

int __fastcall MTreeNodeList::GetNodeIndex(MTreeNode* node) {

   for(int i=0; i < Count; i++) if(Items[i] == node) return i;
   return -1;

   }



/*-------------------------*/
/* MTreeNodeList::GetInfos */
/*-------------------------*/

void __fastcall MTreeNodeList::GetInfos(MTreeInfos& i) {

   static Deep = 0;
   if(!Count) { // no child, Width++
      i.Width++;
      if(Owner != NULL && !Owner->Hidden) i.ShowWidth++;
      return;
      }


   Deep++;
   if(Deep > i.Height) i.Height = Deep;
   if(Deep > i.ShowHeight && Owner!=NULL && !Owner->Hidden) i.ShowHeight = Deep;
   MTreeNode* node;
   for(int n=0; n < Count; n++) { // for all children
      node = static_cast<MTreeNode*>(Items[n]);
      i.NbNodes++;
      i.TextLength += node->Text.Length();
      if(!node->Hidden) {
         i.NbShowNodes++;
         i.ShowTextLength += node->Text.Length();
         }
      node->Children->GetInfos(i);
      }
   Deep--;

  }

/*---------------------*/
/* MTreeNodeList::Draw */
/*---------------------*/

void __fastcall MTreeNodeList::Draw(TCanvas* canvas) {

   for(int n=0; n < Count; n++)
      static_cast<MTreeNode*>(Items[n])->Draw(canvas);

   }

/*------------------------------*/
/* MTreeNodeList::ContainByText */
/*------------------------------*/

MTreeNode* __fastcall MTreeNodeList::ContainByText(AnsiString text,
   bool testSubChildren) {

   MTreeNode* n;
   MTreeNode* m;
   for(int i=0; i < Count; i++) {
      n = static_cast<MTreeNode*>(Items[i]);
      if(eg(text, n->Text)) return n;
      if(testSubChildren) {
         m = n->Children->ContainByText(text,true);
         if(m!=NULL) return m;
         }
      }
   return NULL;

   }


/*---------------------*/
/* MTreeNodeList::ToTV */
/*---------------------*/

void __fastcall MTreeNodeList::ToTV(TTreeNode* parent, TTreeNodes* nodes) {

   MTreeNode* mn;
   TTreeNode* tn;
   for(int i=0; i < Count; i++) {
      mn = static_cast<MTreeNode*>(Items[i]);
      tn = nodes->AddChildObject(parent,mn->Text,mn);
      // TTreeNode::Data is a pointer to the original MTreeNode
       mn->Children->ToTV(tn,nodes);
      }

   }

/*--------------------------*/
/* MTreeNodeList::GetFirst  */
/*--------------------------*/

MTreeNode* __fastcall MTreeNodeList::GetFirst(void) {

   if(Count==0) return(NULL);
   return(static_cast<MTreeNode*>(Items[0]));

   }

// ------------------------------ MTreeNode ----------------------------------

/*----------------------*/
/* MTreeNode::MTreeNode */
/*----------------------*/

__fastcall MTreeNode::MTreeNode() {

   Children = new MTreeNodeList();
   Children->Owner = this;
   Tree = NULL;
   Parent = NULL;
   Text = "NODE";
   TextColor = clRed;
   Hidden = false;

   }

/*-----------------------*/
/* MTreeNode::~MTreeNode */
/*-----------------------*/

__fastcall MTreeNode::~MTreeNode() {

   if(gDeleteNodeDataCB!=NULL && Data!=NULL)
         gDeleteNodeDataCB(Data);
   delete Children;

   }

/*---------------------*/
/* MTreeNode::AddChild */
/*---------------------*/

MTreeNode* __fastcall MTreeNode::AddChild(void* data) {

   return(Children->Add(this, data));

   }

/*---------------------*/
/* MTreeNode::AddChild */
/*---------------------*/

void __fastcall MTreeNode::AddChild(MTreeNode* child) {

   child->Parent = this;
   Children->Add(child);

   }


/*--------------------------*/
/* MTreeNode::AddChildFirst */
/*--------------------------*/

void __fastcall MTreeNode::AddChildFirst(MTreeNode* child) {

   child->Parent = this;
   Children->AddFirst(child);

   }

/*------------------------*/
/* MTreeNode::GetRSibling */
/*------------------------*/

MTreeNode* __fastcall MTreeNode::GetRSibling(void) {

   if(Parent == NULL) return NULL;
   return(Parent->GetRSibling(this));

   }

/*---------------------*/
/* MTreeNode::GetRRoot */
/*---------------------*/

MTreeNode* __fastcall MTreeNode::GetRRoot(void) {

   if(Parent == NULL) return Tree->GetRRoot(this);
   return(Parent->GetRSibling(this));

   }

/*---------------------*/
/* MTreeNode::GetLRoot */
/*---------------------*/

MTreeNode* __fastcall MTreeNode::GetLRoot(void) {

   if(Parent == NULL) return Tree->GetLRoot(this);
   return(Parent->GetLSibling(this));

   }


/*------------------------*/
/* MTreeNode::GetRSibling */
/*------------------------*/

MTreeNode* __fastcall MTreeNode::GetRSibling(MTreeNode* child) {

   int i = GetChildIndex(child);
   if(i>=0 && i < Children->Count-1)
      return(static_cast<MTreeNode*>(Children->Items[i+1]));
   else
      return NULL;

   }

/*--------------------*/
/* MTreeNode::GetRoot */
/*--------------------*/

MTreeNode* __fastcall MTreeNode::GetRoot(void) {

   MTreeNode* m = this;
   while(m->Parent!=NULL)
      m = m->Parent;
   return m;

   }


/*-------------------*/
/* MTreeNode::IsRoot */
/*-------------------*/

bool __fastcall MTreeNode::IsRoot(void) {

   return (Parent == NULL);

   }


/*------------------------*/
/* MTreeNode::GetLSibling */
/*------------------------*/

MTreeNode* __fastcall MTreeNode::GetLSibling(void) {

   if(Parent == NULL) return NULL;
   return(Parent->GetLSibling(this));

   }

/*------------------------*/
/* MTreeNode::GetLSibling */
/*------------------------*/

MTreeNode* __fastcall MTreeNode::GetLSibling(MTreeNode* child) {

   int i = GetChildIndex(child);
   if(i!=NULL && i > 0)
      return(static_cast<MTreeNode*>(Children->Items[i-1]));
   else
      return NULL;

   }

/*--------------------------*/
/* MTreeNode::GetChildIndex */
/*--------------------------*/

int __fastcall MTreeNode::GetChildIndex(MTreeNode* child) {

   return Children->GetNodeIndex(child);

   }


/*--------------------------*/
/* MTreeNode::GetFirstChild */
/*--------------------------*/

MTreeNode* __fastcall MTreeNode::GetFirstChild(void) {

   if(Children->Count > 0)
      return(static_cast<MTreeNode*>(Children->Items[0]));
   return NULL;

   }


/*---------------------------------*/
/* MTreeNode::GetFirstVisibleChild */
/*---------------------------------*/

MTreeNode* __fastcall MTreeNode::GetFirstVisibleChild(void) {

   MTreeNode* child;
   for(int i=0; i < Children->Count; i++) {
      child = static_cast<MTreeNode*>(Children->Items[i]);
      if(!child->Hidden) return child;
      }
   return NULL;

   }


/*--------------------------------*/
/* MTreeNode::GetLastVisibleChild */
/*--------------------------------*/

MTreeNode* __fastcall MTreeNode::GetLastVisibleChild(void) {

   MTreeNode* child;
   for(int i = Children->Count-1; i >= 0; i--) {
      child = static_cast<MTreeNode*>(Children->Items[i]);
      if(!child->Hidden) return child;
      }
   return NULL;

   }


/*---------------------------------*/
/* MTreeNode::GetNbVisibleChildren */
/*---------------------------------*/

int __fastcall MTreeNode::GetNbVisibleChildren(void) {

   int rv=0;
   for(int i=0; i < Children->Count; i++) {
      if(!static_cast<MTreeNode*>(Children->Items[i])->Hidden) rv++;
      }
   return rv;

   }

/*-----------------------------*/
/* MTreeNode::GetNbDescendants */
/*-----------------------------*/

int __fastcall MTreeNode::GetNbDescendants(void) {

   int rv = Children->Count;
   for(int i=0; i < Children->Count; i++) {
      rv += static_cast<MTreeNode*>(Children->Items[i])->GetNbDescendants();
      }
   return rv;

   }


/*-----------------*/
/* MTreeNode::Draw */
/*-----------------*/

void __fastcall MTreeNode::Draw(TCanvas* canvas) {

   if(Hidden) {
      Coords.x = gAbs;
      return;
      }
   // First calcul the children's Coords
   int nbVisibleChildren = GetNbVisibleChildren();
   if(nbVisibleChildren > 0) {
      gOrd += gOrdS;
      Children->Draw(canvas);
      gAltern = false; // parent always up
      gOrd -= gOrdS;
      MTreeNode* FirstChild = GetFirstVisibleChild();
      MTreeNode* LastChild = GetLastVisibleChild();
      if(FirstChild==NULL)
         ShowMessage("NULL1");
      if(LastChild==NULL)
         ShowMessage("NULL2");

      if(nbVisibleChildren==1)
         Coords.x = FirstChild->Coords.x;
      else
         Coords.x = (FirstChild->Coords.x + LastChild->Coords.x)/2;
      }
   else {
      Coords.x = gAbs;
      gAbs += gAbsS;
      }


   Coords.y = gOrd;
   // Draw the arrows to children
   for(int i=0; i < Children->Count; i++)
      if(!static_cast<MTreeNode*>(Children->Items[i])->Hidden)
         Arrow(canvas, Coords,
            static_cast<MTreeNode*>(Children->Items[i])->Coords, clBlack);
   // then display the point with text
   // Alternate the display : one up, one down
   if(//Tree!=NULL && Tree->AlternateText
         gAbsS < canvas->TextWidth(CompressStr(Text,55)) && gAltern==true) {
      gAltern = false;
      DisplayPoint(canvas, Coords, 90, CompressStr(Text,55), TextColor,
         clBlack, 25);
      }
   else {
      gAltern = true;
      DisplayPoint(canvas, Coords, 90, CompressStr(Text,55), TextColor,
         clBlack, 10);
      }

   }


/*--------------------------*/
/* MTreeNode::IsChildByText */
/*--------------------------*/

MTreeNode* __fastcall MTreeNode::IsChildByText(AnsiString text,
   bool testSubChildren) {

   return(Children->ContainByText(text,testSubChildren));

   }

void __fastcall MTreeNode::SortDescendants(void) {

   Children->Sort(SortCompare);

   }

// ------------------------------ MTree -----------------------------------



/*----------------*/
/* MTree::Prepare */
/*----------------*/

void __fastcall MTree::Prepare(void) {

   Roots = new MTreeNodeList();
   Roots->Tree = this;
   AlternateText = false;
   ImageTitle = "";

   }

/*--------------*/
/* MTree::MTree */
/*--------------*/

__fastcall MTree::MTree() {

   Prepare();
   gDeleteNodeDataCB = NULL;

   }


/*--------------*/
/* MTree::MTree */
/*--------------*/

__fastcall MTree::MTree(MCallBackVoidP dNDCB) {

   Prepare();
   gDeleteNodeDataCB = dNDCB;

   }

/*---------------*/
/* MTree::~MTree */
/*---------------*/

__fastcall MTree::~MTree() {

   //ShowMessage("delete MTree");
   delete Roots;

   }

/*--------------*/
/* MTree::Clear */
/*--------------*/

void __fastcall MTree::Clear(void) {

   Roots->Clear();

   }

/*------------*/
/* MTree::Add */
/*------------*/

MTreeNode* __fastcall MTree::Add(void* data) {

   return(Roots->Add(data));

   }

/*------------*/
/* MTree::Add */
/*------------*/

void __fastcall MTree::Add(MTreeNode* node) {

   Roots->Add(node);

   }

/*-----------------*/
/* MTree::AddFirst */
/*-----------------*/

void __fastcall MTree::AddFirst(MTreeNode* node) {

   Roots->AddFirst(node);

   }


/*-------------------*/
/* MTree::DeleteNode */
/*-------------------*/

void __fastcall MTree::DeleteNode(MTreeNode* node) {

   if(node->Parent == NULL)
      Roots->DeleteNode(node);
   else
      node->Parent->Children->DeleteNode(node);
   // TODO: if a TreeView is associated with this tree delete also the TV node
   // Do the same when addind a node
   // ToTV should not be used every time we change the tree !!!

   }

/*---------------------*/
/* MTree::GetFirstRoot */
/*---------------------*/

MTreeNode* __fastcall MTree::GetFirstRoot(void) {

   if(Roots->Count>0) return static_cast<MTreeNode*>(Roots->Items[0]);
   else return NULL;

   }

/*-------------*/
/* MTree::Draw */
/*-------------*/

void __fastcall MTree::Draw(TCanvas* canvas, int w, int h, int mX, int mY) {

   MTreeInfos i;
   GetInfos(i);
   /*
   ShowMessage(i.Width);       ShowMessage(i.ShowWidth);
   ShowMessage(i.Height);      ShowMessage(i.ShowHeight);
   ShowMessage(i.NbNodes);     ShowMessage(i.NbShowNodes);
   ShowMessage(i.TextLength);  ShowMessage(i.ShowTextLength);
   */
   if(i.NbShowNodes==0) return;

   gWidth = w;   gHeight = h;   gMarginX = mX;   gMarginY = mY;

   if(i.ShowWidth == 1) { gAbs = w/2; gAbsS = 1; }
   else { gAbs = mX; gAbsS = (w-mX*2) / (i.ShowWidth-1); }
   if(i.ShowHeight==1) {  gOrd = h/2;  gOrdS = (h-mY*2) / (i.ShowHeight); }
   else { gOrd = mY; gOrdS = (h-mY*2) / (i.ShowHeight-1); }

   if(gOrdS > (h-mY*2)/2)
      gOrdS = (h-mY*2)/2;

   gAltern = false;
   AddTitle(canvas,ImageTitle);
   canvas->Font->Name = "Arial";
   canvas->Font->Size = 8;
   Roots->Draw(canvas);

   }

/*-----------------*/
/* MTree::GetInfos */
/*-----------------*/

void __fastcall MTree::GetInfos(MTreeInfos& i) {

   i.Width = 0;      i.ShowWidth = 0;
   i.Height = 0;     i.ShowHeight = 0;
   i.NbNodes = 0;    i.NbShowNodes = 0;
   i.TextLength = 0; i.ShowTextLength = 0;

   Roots->GetInfos(i);
   if(i.NbNodes!=0)
      i.TextLength /= i.NbNodes;
   if(i.NbShowNodes!=0)
      i.ShowTextLength /= i.NbShowNodes;

   }


/*-----------------*/
/* MTree::SaveDraw */
/*-----------------*/

void __fastcall MTree::SaveDraw(AnsiString fn) {

   try {
      Graphics::TBitmap* bmp = new Graphics::TBitmap();
      ResizeBmp(bmp);

      Draw(bmp->Canvas, bmp->Width, bmp->Height, 60, 80);
      AddFrame(bmp,TColor(0));
      TGIFImage* g = new TGIFImage();
      g->Assign(bmp);
      delete bmp;
      g->SaveToFile(fn);
      delete g;
      }
   catch(...) {
      ShowMessage(AnsiString("Could not save the tree's image.\n")
         + "This could be due to a too large image.");
      }


   }

/*------------------*/
/* MTree::ResizeBmp */
/*------------------*/

int __fastcall MTree::ResizeBmp(Graphics::TBitmap* bmp) {

      MTreeInfos i;
      GetInfos(i);
      int h,w;
      w  = i.ShowWidth*(i.ShowTextLength*6);
      if(w > 15000) w = 15000;
      h = i.ShowHeight*(80);
      if(h>5000) h = 5000;
      bmp->Width = w;
      bmp->Height = h;
      return(i.ShowTextLength);

      }

/*----------------------*/
/* MTree::ContainByText */
/*----------------------*/

MTreeNode* __fastcall MTree::ContainByText(AnsiString text) {

   return(Roots->ContainByText(text,true));

   }


/*-------------*/
/* MTree::ToTV */
/*-------------*/

void __fastcall MTree::ToTV(TTreeView* tv) {

   Roots->ToTV(NULL,tv->Items);

   }


void __fastcall MTree::Sort(int key, int reverse) {

   Roots->Sort(SortCompare);
   for(int i=0; i < Roots->Count; i++)
      static_cast<MTreeNode*>(Roots->Items[i])->SortDescendants();

   }


int __fastcall MTree::GetRootIndex(MTreeNode* n) {

   for(int i=Roots->Count-1; i >= 0; i--)
      if(Roots->Items[i] == n) return i;
   return -1;

   }


MTreeNode* __fastcall MTree::GetRRoot(MTreeNode* n) {

   int i = GetRootIndex(n);
   if(i == -1 || i == Roots->Count-1) return NULL;
   return static_cast<MTreeNode*>(Roots->Items[i+1]);

   }


MTreeNode* __fastcall MTree::GetLRoot(MTreeNode* n) {

   int i = GetRootIndex(n);
   if(i == -1 || i == 0) return NULL;
   return static_cast<MTreeNode*>(Roots->Items[i-1]);

   }

