"clients" contains all clients code

- in gui you will find the official GUI
- in lib you will find useful code you can use to code your own client
- in brains you will find AI clients

To launch the GUI read the Release note in the 'gui' folder.
To launch a brain (an AI client) go into the brains folder and type "ruby main.rb".

There is only one entry point (main.rb) for each brain but you can change that as you want.
To load a new brain use the brain parameter:
ruby main.rb brain=mybrain

main.rb parameters are:
brain :  the brain to load
ip    :  the server ip
port  :  the server port
