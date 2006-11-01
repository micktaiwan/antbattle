/***************************************************************************
                          MMap.h  -  description
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

#ifndef MMAPH
#define MMAPH
/**
  *@author Mickael Faivre-Macon
  */

#include <string>
#include <vector>
#include <map>
#include "Msg.h"

class MMapObject;
  
class MMap {
public: 

   typedef std::map<unsigned long,MMapObject*> MM;
   typedef MM::iterator MMapIte;
   typedef std::vector<MMapObject*> MObjList;

   MM Objects;

   MMap();
   ~MMap();

   void        Clear() {Objects.clear();}
   void        ClearAnt();
   void        SetSize(int w, int h) {W=w;H=h;}
   void        SetObs(int x, int y);
   void        GetSize(int& w, int& h) {w=W;h=H;}
   void        AddObject(MMapObject* obj);
   void        RemoveObject(MMapObject* obj);
   MMapObject* GetObjectByID(unsigned long ID);
   void        DataString(mnetmsg::base&);
   MObjList    GetObjects(int x, int y);


private:
   int W, H;
   };

#endif
