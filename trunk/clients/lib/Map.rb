require 'Utils'

#=========================================
class MapObject
   attr_accessor :x, :y, :object_type, :object_id

   def initialize
      @x = @y = 0
   end

   def to_s
      "type#{object_type},id#{object_id}(#{x},#{y})"
   end
   
end
#=========================================
class Resource < MapObject
   attr_accessor :rtype

   def initialize
      super()
      @object_type = 1
   end

   def to_s
      "ResType:#{rtype},id#{object_id}(#{x},#{y})"
   end
   
end
#=========================================
class Obstacle < Resource

   def initialize
      super()
      @rtype = 255
   end

   def to_s
      "Obs#{object_id}(#{x},#{y})"
   end
   
end

#=========================================
class Ant < MapObject
   attr_accessor :life, :client_id, :ant_type

   def initialize
      super()
      @object_type = 0
   end
   
   def to_s
      "Ant#{object_id}(#{x},#{y})"
   end
  
end

#=========================================
class Warrior < Ant

   def initialize
      super()
      @life = 25
      @ant_type = 0
   end

   #def initialize(client_id, ant_id, ant_type, life)
   #  super()
   #  @client_id, @object_id, @ant_type, @life=client_id, ant_id, ant_type, life
   #end
   
   def to_s
      "Warrior#{object_id}(#{x},#{y})"
   end
end

class Ressource < MapObject
   attr_accessor :resource_type
   
   def initialize(resource_type)
     @object_type = 255
     @resource_type=resource_type
   end

  def describe
    "Ressource #{resource_type}"
  end
end

class Map

   attr_reader   :w, :h, :hash
   attr_accessor :side,:xside

   def initialize(map=nil)
      if(map==nil)
         @side  = -1
         @xside = -1
         @w = 0
         @h = 0
         @hash = Hash.new(nil)
         @joueurs=[]
      else
         @side  = map.side
         @xside = map.xside
         @w = map.w
         @h = map.h
         @hash = Hash.new(nil)
         map.hash.each { |k,v|
            a = deep_copy(v)
            @hash[k] = a
            }
      end
   end

   def set_size(w,h)
      @hash.clear
      @joueurs=[]
      @w = w.to_i
      @h = h.to_i
   end

   def get_object(id)
      if @hash[id] == nil
         puts "nil for #{id}"
      end
      @hash[id]
   end

   def remove_object(id)
      #puts "#{id} is dead"
      @hash.delete(id)
   end
   
   def move(id,x,y)
      o = @hash[id]
      raise "This object is not in the map, maybe we not have receive the map yet?" if o == nil
      o.x = x
      o.y = y
   end

  #def setup(grid)
  #    set_size(*translate_a_msg("BB",grid))
  #    while grid[0]!=nil
  #      x, y, typeobject=translate_a_msg("BBB",grid)
  #       if typeobject==0 # unit
  #         add_object(x,y,Warrior.new(*translate_a_msg("SSBB",grid))) 
  #       else # resource
  #          add_object(x,y,Resource.new(translate_a_msg("b",grid)[0])) 
  #       end
  #    end    
  #  end
   
   def new_game(myid,id1,id2)
      @side    = id1.to_i
      @xside   = id2.to_i
   end
    
   def allies_each
      @hash.each_value { |v| yield v if (v.object_type==0 and v.client_id==side) }
   end
   
   def ennemies_each
      @hash.each_value { |v| yield v if (v.object_type==0 and v.client_id!=side) }
   end
   
   def setup(msg)
      puts "Map Setup"
      set_size(msg[2],msg[3])
      i = 4
      while(i < msg.size)
         object_id = get_param_from(msg,i);            i += object_id.size+1
         x = msg[i];         i += 1
         y = msg[i];         i += 1
         type = msg[i]; i += 1
         object = nil
         case type
         when 0 # ant
            client_id = get_param_from(msg,i);            i += client_id.size+1
            type_fourmi = msg[i]; i += 1
            life = msg[i];        i += 1
            case type_fourmi
               when 0
                  object = Warrior.new
               else
                  puts "Ant type not implemented: #{type_fourmi}"
                  return
            end
            object.object_id = object_id.to_i
            object.x = x
            object.y = y
            object.life = life
            object.client_id = client_id.to_i
         when 1 # resource
            type_resource = msg[i]; i += 1
            case type_resource
            when 255
               object = Obstacle.new
               object.object_id = object_id.to_i
               object.x = x
               object.y = y
            else
               puts "Resource type not implemented: #{type_resource}"
               return
            end
         else
            puts "Object type not implemented: #{type}"
            return
         end # case type
         add_object(object)
      end # while object
   end

   def get_object(id)
      puts "nil for #{id}" if @hash[id] == nil
      @hash[id]
   end

   def add_object(o)
      raise "Map#add_object: adding nil ???"  if o == nil
      @hash[o.object_id] = o
      return
      puts "   ObjectID: #{o.object_id}"
      puts "      Coord: #{o.x} #{o.y}"
      puts "      TypeObject: #{o.object_type}"
      case o.object_type
      when 0 # ant
      puts "         AntType: #{o.ant_type}"
      puts "         ClientID: #{o.client_id}"
      puts "         Life: #{o.life}"
      when 1 # resource
      puts "         ResourceType: #{o.rtype}"
      end
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

   def joueur(a)
      #~ @units=@hash.values.delete_if {|x| (x.object_type!=0 || x.client_id!=a)}         x.object_type!=0}.delete_if
      id=@joueurs[a]
      @units=@hash.values.delete_if {|x| x.client_id!=id || x.object_type!=0 }
      #~ puts "taille " + @units.size.to_s
      @units
   end
      
   def joueurs() 
      if @joueurs==nil || @joueurs.size<2
         @joueurs=(@hash.values.delete_if {|x| x.object_type!=0}).map!{|x| x.client_id}.uniq.sort
      end  
      #~ puts "joueurs : " + @joueurs.join("-")
      @joueurs
   end


   def change_side
      @side, @xside = @xside, @side
      #log 3, 3, "Changing side: #{@side} to play"
   end
   
  
   def exists?(ant)
      #puts ant
      @hash.has_key?(ant.object_id)
   end
   
end
