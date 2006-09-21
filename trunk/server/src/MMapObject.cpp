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

MMapObject::MMapObject() : ID(0), Pos(Vector(0,0)) {

   }
   
MMapObject::~MMapObject(){

   }

