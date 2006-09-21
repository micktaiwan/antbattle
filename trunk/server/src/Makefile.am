## Process this file with automake to produce Makefile.in

## Created by Anjuta - will be overwritten
## If you don't want it to overwrite it,
## 	Please disable it in the Anjuta project configuration

INCLUDES =\
	 -I/usr/include -I../include

AM_CXXFLAGS =\
	 -Wall\
	 -O2

bin_PROGRAMS = antbattleserver

antbattleserver_SOURCES = \
	AntClient.cpp\
	AntServer.cpp\
	HTTPServer.cpp\
	MMap.cpp\
	MMapObject.cpp\
	Stats.cpp\
	main.cpp\
	MPNLBase.cpp\
	NetMsgUtils.cpp\
	MThread.cpp\
	MUtils.cpp

antbattleserver_LDFLAGS = 

antbattleserver_LDADD = \
	 -lboost_thread

