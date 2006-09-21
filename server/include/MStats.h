//---------------------------------------------------------------------------

#ifndef MStatsH
#define MStatsH
#include <string>
#include <vector>

//---------------------------------------------------------------------------
struct MStat {

   MStat() : NbConn(0), Win(0), Loss(0) {}
   std::string Name, LastConn;
   int NbConn, Win, Loss;

   };


//---------------------------------------------------------------------------
class MClientStats {
public:
   typedef std::vector<MStat*>MList;

   MClientStats() {}
   ~MClientStats() {Clear();}

   MStat* Add(const std::string& name);
   MStat* Get(const std::string& name);
   MStat* SafeGet(const std::string& name);
   void Clear();

//private:
   MList List;
};






#endif

