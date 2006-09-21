/***************************************************************************
                          MMap.cpp  -  description
                             -------------------
    begin                : August 2006
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

#include "MMap.h"
#include "MMapObject.h"

#include <sstream>

extern void WriteToLog(int t, const std::string& msg);

//---------------------------------------------------------------------------
MMap::MMap() : W(20),H(20) {

   }

//---------------------------------------------------------------------------
MMap::~MMap(){

   }

//---------------------------------------------------------------------------
void MMap::AddObject(MMapObject* obj) {

   Objects[obj->ID] = obj;

   }

//---------------------------------------------------------------------------
void MMap::RemoveObject(MMapObject* obj) {
// does not delete the object

   std::ostringstream s;
   s << "removing object " << obj->ID << " from map";
   WriteToLog(3,s.str());
   MMapIte ite = Objects.find(obj->ID);
   if(ite==Objects.end()) {
      WriteToLog(1,"MMap::RemoveObject: can not find object");
      return;
      }
   Objects.erase(ite);

   }

//---------------------------------------------------------------------------
MMapObject* MMap::GetObjectByID(unsigned long id) {

   MMapIte ite = Objects.find(id);
   if(ite==Objects.end()) return NULL;
   return ite->second;

   }

//---------------------------------------------------------------------------
void MMap::DataString(mnetmsg::base& m) {

   m.addByte(W);
   m.addByte(H);
   MMapIte ite = Objects.begin();
   while(ite!=Objects.end()) {
      ite->second->DataString(m);
      ++ite;
      }

   }

//---------------------------------------------------------------------------
MMap::MObjList MMap::GetObjects(int x, int y) {

   MObjList rv;

   MMapIte ite = Objects.begin();
   while(ite!=Objects.end()) {
      if(ite->second->Pos.X == x && ite->second->Pos.Y == y)
         rv.push_back(ite->second);
      ++ite;
      }

   return rv;

   }

