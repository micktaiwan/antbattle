require 'socket'
require "TCPClient.rb"
require "AntClient.rb"
require "Utils.rb"
require "Map.rb"


class GuiClient

attr_accessor :map

def initialize(ip,port)
		@version = "0.5"
    @progname = "GUI"
		puts "GUI - Ant Battle GUI"+@version
		puts "   Esc to close"
    puts "   Connecting to #{ip}:#{port}..."
		@tcp = TCPClient.new(ip,port)
		@id = -1
    @client_list = AntClientList.new
    @gameinProgress = false
    @map=Map.new
    @message="GuiClient initialized\n"
    end
    

def run
    begin
			  @tcp.connect
         # send my infos
         send_msg "Connection to server"
         puts "send my infos"
			  @tcp.formatsend("Aa1~"+@progname+"~"+@version+"~http://faivrem.googlepages.com/antbattle")
         # subscribe to connections
         puts " subscribe to connections"
         @tcp.send("Ac1");
         # request client list
         puts " request client list"
         @tcp.send("Ab")
         # subscribe to chats
         puts " subscribe to chats"
         @tcp.send("Db1");
         # subscribe to chats
         while(1)
          begin
                 @msg = ""
                 timeout(20) {
                    @msg = @tcp.read
                    }
          rescue Timeout::Error
          send_msg "No game in progress / no move for 20 seconds"
          end
          if(@msg != "")
             begin
                parse(@msg) 
             rescue Exception => e
             puts "****** Parse msg error: #{ e.message } - (#{ e.class })" << "\n" <<  (e.backtrace or []).join("\n")
             end
          end
        end
     rescue Errno::EBADF => e
     raise "connection problem... #{ e.message }" 
     end
 
	end


def parse(msg)
#puts "   recv: #{msg}"
s = msg.size

raise "msg len < 2" if s < 2
apacket=msg.split("")

typeaction=apacket.shift
action=apacket.shift
#~ print typeaction + action + ""
		case typeaction
			when "A" #Client management message
				case action
					when 'a' # ID/Server Version
                  puts "ID"
                  id, server_version  = translate_a_msg("ss",apacket)
						      @id = id.to_i
                  puts "   === CAUTION: PROTOCOL VERSIONS ARE DIFFERENT ! ===" if server_version != @version
						      puts "   ID: #{@id}, Server: #{server_version}"
					when 'b' # Client list
                  puts "Client list:"
                  tbl_cl=translate_msg("sssss",apacket)
                  tbl_cl.each { |c| @client_list.add(AntClient.new(*c)) }
                  puts "   We have received #{@client_list.list.size} clients"
                  puts get_client_info
					when 'c' # Client connection
                  c=AntClient.new(*translate_a_msg("sssss",apacket))
                  @client_list.add(c) 
                  puts "Connection of #{c.id} (Type:#{c.type}): #{c.name} #{c.version} #{c.free_text}"
					when 'd' # Client disconnection
                  puts apacket.join("-") + msg
                  id = translate_a_msg("S",apacket)[0]
                  c = @client_list.get_id(id)
                  @client_list.remove_id(id)
                  puts "Disconnection of #{c.id} (Type:#{c.type}): #{c.name} #{c.version} #{c.free_text}"
   			  else
   				        puts "Unknown msg type for #{action}"
				end
			when "B" # Game
            case action
               when "a" # Error msg
                  puts "Server error "+get_param(msg,1)+": "+get_param(msg,2)
                  # TODO process error types
               when "b" # New game
                  id1, id2 = translate_a_msg("SS",apacket)
                  c1 = @client_list.get_id(id1)
                  c2 = @client_list.get_id(id2)
                  raise "c1 is nil" if c1 == nil
                  raise "c2 is nil" if c2 == nil
                  send_msg "New Game : #{c1.name} (#{c1.id}) vs #{c2.name} (#{c2.id})"
                  # are we one of the players ?
                  if(@id==id1 or @id==id2)
                     raise "   Error GUI can't play"
                   end
      			   when 'c' # Map
                  #~ puts "Setup de la map"
                  @map.setup(apacket)           
                  raise "   Error GUI can't have partial view"      
               when "d" # who must play ? #not me
                  id = translate_a_msg("S",apacket)[0]
                  #~ puts "   " + id.to_s + " is expected to play"
               when 'e' # end of game
                  id1, id2, code, freetext = translate_a_msg("SSSs",apacket)
                  c1 = @client_list.get_id(id1)
                  c2 = @client_list.get_id(id2)
                  send_msg "#{c1.name} (#{c1.id}) beats #{c2.name} (#{c2.id}) - #{freetext} (#{code})"
               else
      				puts "Unknown msg type for #{action}"
            end
			when 'C' # Actions
            case action
               when 'b' # move
                  ant_id,x,y=translate_a_msg("SBB",apacket)
                  @map.move(ant_id,x,y)
               when 'c' # attack
						      id1,id,life = translate_a_msg("SSS",apacket)
                  #~ puts "#{id1} attacks #{id},  #{id} life is #{life}"
                  if(life==0)
                     @map.remove_object(id)
                  else
                     @map.get_object(id).life = life
                  end                  
            	else
      				puts "Unknown msg type for #{action}"
            end
			when 'D' # Chat
            case action
               when 'a' # chat msg
                  id,msg = translate_a_msg("Ss",apacket)
                  c = @client_list.get_id(id)
                  send_msg c.name+": "+msg
      			else
      				puts "Unknown msg type for #{action}"
            end
			when 'E' # Map
            case action
      			when 'c' # Map
                  @map.setup(apacket)
      			else
      				puts "Unknown msg type for #{action}"
            end
         else
				puts "Unknown msg type for #{typeaction}"
      end
$stdout.flush      
	end

def send_chat(msg="")
@tcp.formatsend("Da"+msg)
end
  
def get_player_info
  cl=""
  @map.joueurs.each { |id|
  c = @client_list.get_id(id.to_i)
  if c!=nil
    cl+=c.name + "(" + c.id.to_s + ")" + "\n"
    end
  }
  cl
end

def get_client_info
  cl="Client list :\n"
  @client_list.list.values.each { |c|
  cl+=c.describe + "\n"
  }
  cl
end

def get_msg
  msg=@message
  @message=""
  msg
end

def send_msg(a)
  @message+=a+"\n"
end

def destroy
  begin
  @tcp.shutdown if @tcp.status!=nil
  rescue
  puts "@tcp.shutdown failed"
  raise
  end
end

end #end class
