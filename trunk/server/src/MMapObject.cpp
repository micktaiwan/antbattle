/***************************************************************************
                          MMapObject.cpp  -  description
                             -------------------
    begin                : Fri Sep 19 2003
    copyright            : (C) 2003 by Mickael Faivre-Macon
    email                : mickael@easyplay.com.tw
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include "MMapObject.h"

extern void WriteToLog(int t, const std::string& msg);

//---------------------------------------------------------------------------
MMapObject::MMapObject() : ID(0), Pos(Vector(0,0)) {

   }

//---------------------------------------------------------------------------
MMapObject::~MMapObject(){

   }

//---------------------------------------------------------------------------
void MMapObject::DataString(mnetmsg::base& m) {
   m.add(ID);
   m.addByte(Pos.X);
   m.addByte(Pos.Y);
   m.addByte(Type); // object type
   }

//---------------------------------------------------------------------------
void MResource::DataString(mnetmsg::base& m) {
   MMapObject::DataString(m);
   m.addByte(RType); // resource type
   }
//---------------------------------------------------------------------------
void MAnt::DataString(mnetmsg::base& m) {
   MMapObject::DataString(m);
   m.add(ClientID);
   m.addByte(AntType); //  ant type
   m.addByte(Life); // TODO 3: Attention: en fonction du type de jeu
   }

