/***************************************************************************
                          mantclient.h  -  description
                             -------------------
    begin                : August 18 2006
    copyright            : (C) 2006 by Mickael Faivre-Macon
    email                : faivrem@gmail.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef AntClientH
#define AntClientH

#include <string>
#include <vector>
#include <map>
#include "MMapObject.h"
#include "Msg.h"

//---------------------------------------------------------------------------
class MColony {
public:
   typedef std::map<long, MAnt*> MAntList;

   MColony();
   ~MColony();

   void ResetActionPoints();
   void DeleteAnt(long id);
   void AddAnt(MAnt* a) {Ants[a->ID] = a;}
   MAnt* GetAnt(long i) {return Ants[i];}
   int Size() {return Ants.size();}
   void Clear();

private:
   MAntList Ants;

   };

//---------------------------------------------------------------------------
/** This class represent a network client
  * and to not complicate things it also contains colony information
  *@author Mickael Faivre-Macon
  */
class MAntClient {
public:

   std::string    Program, Version, IP, FreeText;
   int   ClientID, Type, ErrorCount, LastActionTime;
   bool           Logged, Playing;
   MColony        Colony;
   std::map<int,int> Services;

   MAntClient();
   ~MAntClient();

   void DataString(mnetmsg::base& m);

private:

   };

//---------------------------------------------------------------------------
class MAntClientList {

public:

   typedef std::map<int,MAntClient*> MList;
   
  MAntClientList() {}
  ~MAntClientList() {Clear();}

  void Clear();

private:
   MList list;

};


#endif
