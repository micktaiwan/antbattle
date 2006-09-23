# this file defines brain and ants goals
# modify this configuration file to modify the client behaviour

require 'Map'
require 'pathfinding'

KILL = 0
PROTECT = 1

class Goal

   attr_accessor :thresold
   
   def initialize
      @cur_thres = 0
      @top_goals = [KILL,PROTECT]
   end

end

class Ant

   attr_accessor :goal
   
   # this function transform a goal into a move
   # it's the main "intelligent" function for an ant
   def get_move
      return nil if goal == nil
      case goal[0]
         when KILL
            e = goal[1] # we get the ennemy
            puts "our ennemy to kill: #{e}"
            #dist = 
            return nil #"Cb#{object_id}~"+[x+3,y].pack('cc')
         end
   end

end


class Colony

   # return a set of [ant,goal]
   def set_goals
      #doing simple: give the goal "kill this ant" for each ant
      x = nil
      @map.ennemies_each { |e|
         x = e
         }
      raise "oops" if x == nil
      @map.allies_each{ |a|
         a.goal = [KILL, x]
         }
      return

      # get state of the game
      #calculate each top goals weight
      @top_goals.each { |g|
         get_weight(g)
         }
   end
   

   def get_weight(g)
      w = 0
      case g
         when KILL
         when PROTECT
      end
      w
   end

end
