require 'Minimax'
require 'Map'
require 'Utils'

class Map
   
   # yield every successor state and the action that leads to the state
   def each_successor 
      # a successor (state) is the result of each ant actions
      # since each ant has 84 possible moves (without counting attack combinaisons),
      # we only generate a random move for each ant, and generates n states
      # then generate n attacks if possible
      # then generate n random move + attack if possible
      # the minimax will do the work for us: select the best state
      
      # Question:
      # the pbm with random moves is that the ennemy does move at random,
      # so the intelligence is null...
      # of n must be high
      # if n is high why not do all the moves ?
      
      log 3,0, "each_successor"
      10.times { |i| # generate n new states
         log 3,3,"times #{i}"
         map = Map.new(self)
         map.change_side()
         moves = []
         map.allies_each { |ant|
            raise "play: having a dead ant" if(ant.life==0)
            rv = map.get_nearby_ennemies(ant)
            if(rv.size>0) # we are near an ennemy
               # give the choice between 2 states: attack or move
               m = "Cc#{ant.object_id}"+[27].pack("c")+"#{rv[0].object_id}" # attack
   				#puts "attack: #{sanitize(m)}"
               moves << m
               map2 = Map.new(self)
               map2.preattack_from_msg(m)
               #puts "yielding attack"
               yield map2, moves
            end
            # random coordinates
            x = ant.x + rand(7)-3
            y = ant.y + rand(7)-3
            if(x<0); x = 0; end
            if(y<0); y = 0; end
            if(x >= map.w); x = map.w-1; end
            if(y >= map.h); y = map.h-1; end
            m = "Cb#{ant.object_id}"+[27,x,y].pack("ccc") # move it
            #puts "move: #{sanitize(m)}"
            moves << m
            map.move_from_msg(m)
            yield map, moves
            }
         # TODO: combinaison of move and attack
         }
         
   end
   
   
   # the heuristic that values the state
   def value
      # power = sum of lifes - sum of ennemy lifes
      sum = 0
      allies_each   { |ant| sum += ant.life }
      ennemies_each { |ant| sum -= ant.life }
      sum
      #get the distance from 49,49
      #dist = 0
      #allies_each { |ant|
      #   dist -= (49-ant.x) + (49-ant.y)
      #   }
      #dist
   end
   
   # true iff no successor states can be generated
   def final?
      return nil
   end
   
   def get_nearby_ennemies(ant)
      rv = []
      ennemies_each { |e|
         rv << e if (((ant.x-e.x).abs + (ant.y-e.y).abs) <= 1)
         }
      rv
   end
   
   def to_s
      puts "yo"
   end

end   


class Colony
   
   def init
      @progversion = "0.1"
      @progname = "Minimax"
      @freetext = ""
   end      

   def play
      moves = get_moves
      if(moves != nil)
         moves.each { |m| @tcp.formatsend(m) }
      end
      @tcp.send("Ca")
   end

   def get_moves
      value, moves = alpha_beta(@map,3)
      puts "value=#{value}: moves=#{sanitize(moves.join(','))}" if moves != nil
      moves
   end
  
   
end
