/***************************************************************************
                          mantclient.cpp  -  description
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

#include "AntClient.h"
//#include "MUtils.h"
#include <sstream>
using namespace std;
using namespace mnetmsg;

extern void WriteToLog(int, const std::string&);

//---------------------------------------------------------------------------
void MAnt::DataString(base& m) {

   m.addByte(Pos.X);
   m.addByte(Pos.Y);
   m.addByte(0); // Type object
   m.add(ClientID);
   m.add(ID);
   m.addByte(Type); // Type fourmi
   m.addByte(Life); // TODO 2: Attention: en fonction

   }

//---------------------------------------------------------------------------
MColony::MColony() {


   }

//---------------------------------------------------------------------------
MColony::~MColony() {

   Clear();

   }

//---------------------------------------------------------------------------
void MColony::Clear() {

   MAntList::iterator ite = Ants.begin();
   while(ite!=Ants.end()) {
      delete ite->second;
      ++ite;
      }
   Ants.clear();
   
   }

//---------------------------------------------------------------------------
void MColony::ResetActionPoints() {

   MAntList::iterator ite = Ants.begin();
   while(ite!=Ants.end()) {
      ite->second->ActionPoints = 8; // TODO 3: rendre ca configurable
      ++ite;
      }

   }
   
//---------------------------------------------------------------------------
void MColony::DeleteAnt(unsigned long id) {

   ostringstream s;
   s << "deleting ant " << id;
   WriteToLog(3,s.str());

   MAntList::iterator ite = Ants.begin();
   while(ite!=Ants.end()) {
      if(ite->second->ID == id) {
         delete ite->second;
         Ants.erase(ite);
         return;
         }
      ++ite;
      }

   WriteToLog(1,"MColony::DeleteAnt: can not find object");
   return;

   //MAntList::iterator ite = Ants.find(id);
   //if(ite==Ants.end()) {
   //   WriteToLog(1,"MColony::DeleteAnt: can not find object");
   //   return;
   //   }

   }

//---------------------------------------------------------------------------
MAntClient::MAntClient() : ErrorCount(0), Logged(false), Playing(0) {}

//---------------------------------------------------------------------------
MAntClient::~MAntClient(){}

//---------------------------------------------------------------------------
void MAntClient::DataString(base& m) {

   m.add(ClientID);
   m.add(Type);
   m.add(Program);
   m.add(Version);
   m.add(FreeText);
   //m.add(IP);

   }

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
void MAntClientList::Clear() {

   MList::iterator ite;
   for(ite=list.begin(); ite!=list.end();ite++) {
      delete ite->second;
      }
   list.clear();

   }
