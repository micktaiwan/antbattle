/***************************************************************************
                          mworldsobject.h  -  description
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

#ifndef MMAPSOBJECTH
#define MMAPSOBJECTH

#include <string>
#include "Msg.h"

/**
  *@author Mickael Faivre-Macon
  */
//---------------------------------------------------------------------------
class Vector {
public:
   int X,Y;
   Vector(int x, int y) : X(x), Y(y) {}
   };
   
//---------------------------------------------------------------------------
class MMapObject {

public:
   long   ID;
   Vector Pos;
   char   Type;

   MMapObject();
   virtual ~MMapObject();

   virtual void DataString(mnetmsg::base&);

};

//---------------------------------------------------------------------------
class MResource : public MMapObject {
public:
   MResource() {Type=1;}
   virtual ~MResource() {}
   unsigned char RType;
   virtual void DataString(mnetmsg::base&);
   };
//---------------------------------------------------------------------------
class MAnt : public MMapObject {
public:
   MAnt() : Life(10),ActionPoints(8), Speed(6), AntType(0) {Type=0;}
   virtual ~MAnt() {}
   int Life, ClientID, ActionPoints, Speed, AntType;
   virtual void DataString(mnetmsg::base&);
   };

#endif
