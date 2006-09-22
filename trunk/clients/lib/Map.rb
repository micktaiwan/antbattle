require 'Utils'

#=========================================
class MapObject
   attr_accessor :x, :y, :object_type, :object_id

   def initialize
   end

   def to_s
      "#{object_id}(#{x},#{y})"
   end
   
end

#=========================================
class Ant < MapObject
   attr_accessor :life, :client_id, :ant_type

   def initialize
      super()
      @object_type = 0
   end

end

#=========================================
class Warrior < Ant

   def initialize
      super()
      @life = 25
      @ant_type = 0
   end

end

#=========================================
class Map

   attr_reader   :w, :h, :hash
   attr_accessor :side,:xside

   def initialize(map)
      if(map==nil)
         @side  = -1
         @xside = -1
         @w = 0
         @h = 0
         @hash = Hash.new(nil)
      else
         #puts "copying map"
         @side  = map.side
         @xside = map.xside
         @w = map.w
         @h = map.h
         @hash = Hash.new(nil)
         map.hash.each { |k,v|
            a = deep_copy(v)
            #print "#{k}: #{a}"
            @hash[k] = a
            }
         #puts
      end
   end
   
   def new_game(myid,id1,id2)
      if(myid==id1)
         @side    = id1.to_i
         @xside   = id2.to_i
      else
         @side    = id2.to_i
         @xside   = id1.to_i
      end
   end
   
   def change_side
      @side, @xside = @xside, @side
      log 3, 3, "Changing side: #{@side} to play"
   end
   
   def set_size(w,h)
      puts "   Map size: #{w}x#{h}"
      @hash.clear
      @w = w.to_i
      @h = h.to_i
   end
   
   def allies_each
      #puts "a side=#{@side}"
      @hash.each_value { |v| yield v if (v.client_id==side) }
   end
   
   def ennemies_each
      #puts "e side=#{@side}"
      @hash.each_value { |v| yield v if (v.client_id!=side) }
   end
   
   def setup(msg)
      puts "Map Setup"
      set_size(msg[2],msg[3])
      i = 4
      while(i < msg.size)
         x = msg[i];         i += 1
         y = msg[i];         i += 1
         type = msg[i]; i += 1
         if(type==0) # ant
            client_id = get_param_from(msg,i);            i += client_id.size+1
            object_id = get_param_from(msg,i);            i += object_id.size+1
            type_fourmi = msg[i]; i += 1
            life = msg[i];        i += 1
            ant = nil
            case type_fourmi
               when 0
                  ant = Warrior.new
               else
                  puts "Ant type not implemented: #{type_fourmi}"
                  return
            end
            ant.x = x
            ant.y = y
            ant.life = life
            ant.client_id = client_id.to_i
            ant.object_id = object_id.to_i
            add_object(x,y,ant)
         else
            puts "Object type not implemented: #{type}"
            return
         end # type == 0
      end # while object
   end

   def get_object(id)
      if @hash[id] == nil
         puts "nil for #{id}"
      end
      @hash[id]
   end

   def add_object(x,y,o)
      raise "Map#add_object: adding nil ???"  if o == nil
      @hash[o.object_id] = o
      return
      puts "   Coord: #{o.x} #{o.y}"
      puts "      TypeObject: #{o.object_type}"
      puts "      ClientID: #{o.client_id}"
      puts "      ObjectID: #{o.object_id}"
      puts "      ObjectType: #{o.object_type}"
      puts "      AntType: #{o.ant_type}"
      puts "      Life: #{o.life}"
   end

   def remove_object(id)
      #puts "#{id} is dead"
      @hash.delete(id)
   end
   
   def move(id,x,y)
      o = @hash[id]
      raise "Map#move: object #{id} not found in map !" if o == nil
      o.x = x
      o.y = y
   end

   def move_from_msg(msg)
      #puts sanitize(msg)
      arg = parse_msg(msg,"bbsbb")
      move(arg[2].to_i,arg[3].to_i,arg[4].to_i)
   end
   
   def attack_from_msg(msg)
      id1 = get_param(msg,1).to_i
      id2 = get_param(msg,2).to_i
      life = get_param(msg,3).to_i
      obj = get_object(id2)
      obj.life = life
      log 3,6, "REAL: #{id1} attacks #{id2},  #{id2} life is #{life}"
      remove_object(obj.object_id) if(life == 0)
   end


   def preattack_from_msg(msg)
      #msg = m[2,m.size()-1]
      #puts sanitize(msg)
      id1 = get_param(msg,1).to_i
      id2 = get_param(msg,2).to_i
      #life = get_param(msg,3).to_i
      obj = get_object(id2)
      obj.life -= 5
      log 3,6, "PRE: #{id1} attacks #{id2},  #{id2} life is #{obj.life}"
      remove_object(obj.object_id) if(obj.life == 0)
   end
   
   def get_objects(x,y)
      rv = []
      @hash.each_value { |obj|
         rv << obj if(obj.x==x and obj.y==y)
         }
      rv
   end
end
