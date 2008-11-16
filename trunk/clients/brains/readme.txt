How to write a bot ?
==================


The class to implement is Colony.
The class in the lib folder contains the tcp client and all helping code you need.

main.rb will load your brain and call
c = Colony.new(ip,port)
c.run
You have to implement init() that will initialize
@progname
@progversion
@freetext

Then implement play()
play() will be called when your turn to play comes (see colony.rb in lib)

