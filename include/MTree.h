#ifndef MTreeH
#define MTreeH

#include "CallBack.h"
#include <comctrls.hpp>

//typedef int __fastcall (*TListSortCompare)(void * Item1, void * Item2);

struct MTreeInfos {
   int Width;       int ShowWidth;
   int Height;      int ShowHeight;
   int NbNodes;     int NbShowNodes;
   int TextLength;  int ShowTextLength;
   };

class MTreeNodeList;
class MTreeNode;
class MTree;

class MTreeNodeList : public TList {

   public:
      MTree* Tree;
      MTreeNode* Owner;

      __fastcall MTreeNodeList();
      virtual __fastcall ~MTreeNodeList();
      virtual void         __fastcall AddFirst(MTreeNode* node);
      virtual void         __fastcall Add(MTreeNode* node);
      virtual MTreeNode*   __fastcall Add(MTreeNode* parent, void* data);
      virtual MTreeNode*   __fastcall Add(void* data);
      virtual void         __fastcall DeleteNode(MTreeNode* node);
      virtual int          __fastcall GetNodeIndex(MTreeNode* node);
      virtual void         __fastcall GetInfos(MTreeInfos& i);
      virtual void         __fastcall Draw(TCanvas* canvas);
              void         __fastcall Clear(void); // overrided
      virtual MTreeNode*   __fastcall ContainByText(AnsiString text,
         bool testSubChildren);
      virtual void         __fastcall ToTV(TTreeNode* parent, TTreeNodes* tn);
      virtual MTreeNode*   __fastcall GetFirst(void);

   };

class MTreeNode {

   public:
      void* Data;
      MTreeNodeList* Children;
      MTreeNode* Parent;
      TPoint Coords;
      AnsiString Text;
      TColor TextColor;
      bool Hidden;
      // TODO: maybe add a "int TVIndex" property
      MTree* Tree;

      __fastcall MTreeNode();
      virtual __fastcall ~MTreeNode();
      virtual MTreeNode* __fastcall AddChild(void* data);
      virtual void       __fastcall AddChild(MTreeNode* child);
      virtual void       __fastcall AddChildFirst(MTreeNode* child);
      virtual MTreeNode* __fastcall GetRoot(void);
      virtual bool       __fastcall IsRoot(void);
      virtual MTreeNode* __fastcall GetFirstChild(void);
      // Get the sibling, but if it is a root, of course there is no sibling
      virtual MTreeNode* __fastcall GetRRoot(void);
      virtual MTreeNode* __fastcall GetLRoot(void);
      // Get a root "false" right sibling or get the sibling,
      // (=not matter if it is a root or not, get the sibling)
      virtual MTreeNode* __fastcall GetRSibling(void);
      virtual MTreeNode* __fastcall GetRSibling(MTreeNode* child);
      virtual MTreeNode* __fastcall GetLSibling(void);
      virtual MTreeNode* __fastcall GetLSibling(MTreeNode* child);
      virtual int        __fastcall GetChildIndex(MTreeNode* child);
      virtual void       __fastcall Draw(TCanvas* canvas);
      virtual MTreeNode* __fastcall IsChildByText(AnsiString text,
         bool testSubChildren);
      virtual MTreeNode* __fastcall GetFirstVisibleChild(void);
      virtual MTreeNode* __fastcall GetLastVisibleChild(void);
      virtual int    __fastcall GetNbVisibleChildren(void);
      virtual int    __fastcall GetNbDescendants(void);
      virtual void   __fastcall SortDescendants(void);

   };


class MTree {

   public:
      MTreeNodeList* Roots;
      bool AlternateText;
      AnsiString ImageTitle;

      __fastcall MTree();
      __fastcall MTree(MCallBackVoidP deleteNodeData);
      void __fastcall Prepare(void);
      virtual __fastcall ~MTree();
      virtual void       __fastcall Clear(void);
      virtual MTreeNode* __fastcall Add(void* data); // Add a root
      virtual void       __fastcall Add(MTreeNode* node);
      virtual void       __fastcall AddFirst(MTreeNode* node);
      virtual void       __fastcall DeleteNode(MTreeNode* node);
      virtual int        __fastcall GetRootIndex(MTreeNode* n);
      virtual MTreeNode* __fastcall GetFirstRoot(void);
      virtual MTreeNode* __fastcall GetRRoot(MTreeNode* n);
      virtual MTreeNode* __fastcall GetLRoot(MTreeNode* n);
      virtual void       __fastcall GetInfos(MTreeInfos& i);
      // if cb==NULL, i.TextLength is always equal to 0
      virtual void       __fastcall Draw(TCanvas* canvas, int w, int h,
         int mX, int mY);
      virtual void       __fastcall SaveDraw(AnsiString fn);
      virtual int        __fastcall ResizeBmp(Graphics::TBitmap* bmp);
      virtual MTreeNode* __fastcall ContainByText(AnsiString text);
      virtual void       __fastcall ToTV(TTreeView* tv);
      // Copy the tree to a VCL::TTreeView
      // TreeNode::Text will be MTreeNode::Text and
      // TTreeNode::Data is a pointer to the original MTreeNode
      // ATTENTION : if the original TTreeNode is deleted,
      // (directely or by deleting the tree) then,
      // 1) TTreeNode::Data will become a fool pointer
      // 2) the TreeView will "remember" only the MTreeNode::Text, all other
      // informations will be lost (if the MTreeNode is in fact
      // a derived class with specific informations like MForumMessage)

      virtual void         __fastcall Sort(int key, int reverse);
      // Sort the tree regarding key.
      // Descendant class must overide the SortCompare method
      //int __fastcall SortCompare(void* item1, void* item2);

   };

#endif

