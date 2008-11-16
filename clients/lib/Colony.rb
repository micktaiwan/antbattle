require 'TCPClient'
require 'Utils'
require 'AntClient'
require 'Map'
require 'timeout'
#begin
#require 'guitk'
#$hasgtk = true
#rescue
$hasgtk = false
#end

class Colony

	def initialize(ip,port)
    @id = -1
    @opp = -1
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
    @gui = GuiTk.new(@map) if $hasgtk
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
      timeout = 3
      while(1) # the main loop
        begin
          @msg = ""
          timeout(timeout) {
            @msg = @tcp.read
            }
        rescue Timeout::Error
          #puts "No game in progress / no move for #{timeout} seconds"
        end
        if(@msg != "")
          begin
            parse(@msg) 
          rescue Exception => e
            puts "****** Parse msg error: #{ e.message } - (#{ e.class })" << "\n" <<  (e.backtrace or []).join("\n")
            raise
          end
        end
      end
    rescue Errno::EBADF => e
      raise "connection problem... #{ e.message }" 
    end
  
  end

  def parse(msg)
      s = msg.size
      
      raise "msg len < 2" if s < 2
      apacket=msg.split("")
      
      typeaction=apacket.shift
      action=apacket.shift
      # print typeaction + action + ""
      case typeaction
         when "A" # Client management message
            case action
               when 'a' # ID/Server Version
                  puts "ID"
                  id, server_version  = translate_a_msg("ss",apacket)
                  @id = id.to_i
                  #puts "   === CAUTION: PROTOCOL VERSIONS ARE DIFFERENT ! ===" if server_version != @version
                  puts "   ID: #{@id}, Server version: #{server_version}"
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
                  er,msg=translate_a_msg("ss",apacket)
                  puts "Server error " + er + "-" + msg
                  puts "Server error " + er + "-" + msg
               when "b" # New game
                  id1, id2 = translate_a_msg("SS",apacket)
                  c1 = @client_list.get_id(id1)
                  c2 = @client_list.get_id(id2)
                  @map.new_game(@id,id1,id2)
                  raise "c1 is nil" if c1 == nil
                  raise "c2 is nil" if c2 == nil
                  puts "New Game : #{c1.name} (#{c1.id}) vs #{c2.name} (#{c2.id})"
                  # are we one of the players ?
                  if(@id==id1 or @id==id2)
                    @gameinProgress = true
                    puts "   I am playing !!!"
                  end
               when 'c' # Map
                  #~ puts "Setup de la map"
                  @map.setup(apacket)           
                  raise "   Error GUI can't have partial view"      
               when "d" # who must play ?
                  id = translate_a_msg("S",apacket)[0]
                  @map.change_side
                  play if(@id == id)
               when 'e' # end of game
                  id1, id2, code, freetext = translate_a_msg("SSSs",apacket)
                  c1 = @client_list.get_id(id1)
                  c2 = @client_list.get_id(id2)
                  puts "#{c1.name} (#{c1.id}) beats #{c2.name} (#{c2.id}) - #{freetext} (#{code})"
                  if(@id==id1)
                    puts " I win !" 
                  else
                    puts " I lose"
                  end  
                  @tcp.send("Bb1") if(@id==id2) # suscribe to a new game
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
            @gui.paint if $hasgtk
         when 'D' # Chat
            case action
               when 'a' # chat msg
                  id,msg = translate_a_msg("Ss",apacket)
                  c = @client_list.get_id(id)
                  puts c.name+": "+msg
               else
                  puts "Unknown msg type for #{action}"
            end
			when 'E' # Map
            case msg[1].chr
      			when 'c' # Map
                  @map.setup(msg)
                  @gui.paint if $hasgtk
      			else
      				puts "Unknown msg type for #{msg[1].chr}"
            end
         else
            puts "Unknown msg type for #{typeaction}"
      end
      $stdout.flush      
	end

  def get_client_info
    cl="Client list :\n"
    @client_list.list.values.each { |c|
      cl+=c.describe + "\n"
      }
    cl
  end

end
