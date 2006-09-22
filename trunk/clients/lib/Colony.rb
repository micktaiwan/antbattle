require 'TCPClient'
require 'Utils'
require 'AntClient'
require 'Map'
require 'timeout'

class Colony

	def initialize(ip,port)
		@id = -1
      @client_list = AntClientList.new
      @gameinProgress = false
      @map = Map.new(nil)
      @progversion = ""
      @progname = ""
      @freetext = ""
		init()
      puts "#{@progname} #{@progversion} - #{@freetext}"
		puts "   Ctrl-C to close"
      puts "   Connecting to #{ip}:#{port}..."
		@tcp = TCPClient.new(ip,port)
   end

	def run
		begin
			@tcp.connect
         # send my infos
			@tcp.formatsend("Aa0~"+@progname+"~"+@progversion+"~"+@freetext)
         # subscribe to connections
         @tcp.send("Ac1");
         # request client list
         @tcp.send("Ab")
         # subscribe to chats
         @tcp.send("Db1");
         # subscribe to games (to play)
         @tcp.send("Bb1");
         # subscribe to games msg (to see others games)
         @tcp.send("Af1");
         while(1)
				begin
               @msg = ""
               timeout(3) {@msg = @tcp.read}
				rescue Timeout::Error
            end
            if(@msg != "")
               begin
                  parse(@msg)
               rescue
                  puts "****** Parse msg error: #{$!}"
                  raise
               end
            end
			end
		rescue
			puts "Error: #{$!}"
         raise
      end
	end

   def parse(msg)
		#puts "   recv: #{sanitize(msg)}"
		#s = msg.size
		#raise "msg len < 2" if s < 2
		case msg[0].chr
			when 'A' #Client management message
				case msg[1].chr
					when 'a' # ID/Server Version
                  puts "ID"
						@id = get_param(msg,1).to_i
                  server_version = get_param(msg,2)
						puts "   ID: #{@id}, Server: #{server_version}"
					when 'b' # Client list
                  puts "Client list:"
                  i = 1
                  id = get_param(msg,i)
						while(id!="")
                     c = AntClient.new
                     c.id = id.to_i
                     i += 1
                     c.type = get_param(msg,i)
                     i += 1
                     c.name = get_param(msg,i)
                     i += 1
                     c.version = get_param(msg,i)
                     i += 1
                     c.free_text = get_param(msg,i)
                     #i += 1
                     #c.ip = get_param(msg,i)
                     i += 1
                     id = get_param(msg,i)
                     @client_list.add(c)
                     puts "   Client #{c.id} (Type:#{c.type}): #{c.name} #{c.version} #{c.free_text} "
                  end
                  puts "   We have received #{@client_list.list.size} clients"
                  # send a chat msg :)
                  #@tcp.formatsend("DaYop, je suis le prog d'exemple")
					when 'c' # Client connection
                  c = AntClient.new
                  c.id = get_param(msg,1).to_i
                  c.type = get_param(msg,2)
                  c.name = get_param(msg,3)
                  c.version = get_param(msg,4)
                  c.free_text = get_param(msg,5)
                  c.ip = get_param(msg,6)
                  @client_list.add(c)
                  puts "Connection of #{c.id} (Type:#{c.type}): #{c.name} #{c.version} #{c.free_text}"
					when 'd' # Client disconnection
                  id = get_param(msg,1).to_i
                  c = @client_list.get_id(id)
                  @client_list.remove_id(id)
                  puts "Disconnection of #{c.id} (Type:#{c.type}): #{c.name} #{c.version} #{c.free_text}"
   			else
   				puts "1Unknown msg type for #{msg[1].chr}"
				end
			when 'B' # Game
            case msg[1].chr
               when 'a' # Error msg
                  puts "Server error "+get_param(msg,1)+": "+get_param(msg,2)
                  # TODO process error types
               when 'b' # New game
                  puts "==== New Game"
                  id1 = get_param(msg,1).to_i
                  id2 = get_param(msg,2).to_i
                  @map.new_game(@id,id1,id2)
                  c1 = @client_list.get_id(id1)
                  c2 = @client_list.get_id(id2)
                  if (c1 != nil and c2 != nil)
                     puts "   #{c1.id} (#{c1.name}) vs #{c2.id} (#{c2.name})"
                  end
                  # are we one of the players ?
                  if(@id==id1 or @id==id2)
                     @gameinProgress = true
                     puts "   I am playing !!!"
                  end
               when 'd' # who must play ?
                  id = get_param(msg,1).to_i
                  if(@id == id)
                     #puts "   My turn"
                     play
                  else
                     #puts "   Not my turn"
                  end
                  # TODO process error types
               when 'e' # end of game
                  id1 = get_param(msg,1).to_i
                  id2 = get_param(msg,2).to_i
                  code = get_param(msg,3).to_i
                  freetext = get_param(msg,4)
                  c1 = @client_list.get_id(id1)
                  c2 = @client_list.get_id(id2)
                  print "==== End of Game"
                  if(@id==id1); puts ": I win !"
                  elsif(@id==id2) # because we could be watching a game
                     puts ": I lose"
                     # subscribe to games (to play again)
                     @tcp.send("Bb1");
                  else
                     puts
                  end
                  puts "   Winner: #{c1.id} (#{c1.name})"
                  puts "   Loser : #{c2.id} (#{c2.name})"
                  puts "   Code  : #{code}"
                  puts "   FreeText: #{freetext}"
               else
      				puts "2Unknown msg type for #{msg[1].chr}"
            end
			when 'C' # Actions
            case msg[1].chr
               when 'b' # move
                  @map.move_from_msg(msg)
               when 'c' # attack
                  @map.attack_from_msg(msg)
               else
                  puts "Unknown msg type for #{msg[1].chr}"
            end
			when 'D' # Chat
            case msg[1].chr
               when 'a' # chat msg
                  id = get_param(msg,1).to_i
                  c = @client_list.get_id(id)
                  #raise "c is nil" if c == nil
                  puts c.name+": "+get_param(msg,2)
      			else
      				puts "3Unknown msg type for #{msg[1].chr}"
            end
			when 'E' # Map
            case msg[1].chr
      			when 'c' # Map
                  @map.setup(msg)
      			else
      				puts "4Unknown msg type for #{msg[1].chr}"
            end
         else
				puts "0Unknown msg type for #{msg[0].chr}"
            puts sanitize(msg)
            raise "error"
		end
	end
  
end
