class MapObject
   attr_accessor :x, :y, :object_type, :object_id

   def initialize
   end

end

class Ant < MapObject
   attr_accessor :life, :client_id, :ant_type

   def initialize
      super()
      @object_type = 0
   end

end

class Warrior < Ant

   def initialize
      super()
      @life = 25
      @ant_type = 0
   end

   def initialize(client_id, ant_id, ant_type, life)
     super()
     @client_id, @object_id, @ant_type, @life=client_id, ant_id, ant_type, life
   end
   
   def describe
      puts "   Coord: #{x} #{y}"
      puts "      TypeObject: #{object_type}"
      puts "      ClientID: #{client_id}"
      puts "      ObjectID: #{object_id}"
      puts "      ObjectType: #{object_type}"
      puts "      AntType: #{ant_type}"
      puts "      Life: #{life}"
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

   attr_reader :w, :h

   def initialize
      @w = 0
      @h = 0
      @hash = Hash.new(nil)
      @joueurs=[]
   end

   def set_size(w,h)
      #~ puts "   Map size: #{w}x#{h}"
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

   def add_object(x,y,o)
      raise "Map#add_object: adding nil ???"  if o == nil
      o.x=x
      o.y=y
      @hash[o.object_id] = o
      #~ o.describe
   end

   def remove_object(id)
      ant = @hash[id]
		#@map.delete(ant.y*ant.x+ant.x)
      @hash.delete(id)
		ant
   end
   
   def move(id,x,y)
      o = @hash[id]
      #raise "Map#move: object #{id} not found in map !" if o == nil
      if o == nil
         puts "This object is not in the map, maybe we not have receive the map yet?"
         return
      end
      o.x = x
      o.y = y
   end

  def setup(grid)
      set_size(*translate_a_msg("BB",grid))
      while grid[0]!=nil
      x, y, typeobject=translate_a_msg("BBB",grid)
      if typeobject==0 #unité
      add_object(x,y,Warrior.new(*translate_a_msg("SSBB",grid))) 
        else #resource
        add_object(x,y,Resource.new(translate_a_msg("b",grid)[0])) 
        end
      end    
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


 #~ def [](a,b)
 #~ end
 
end

