# this file defines brain and ants goals
# modify this configuration file to modify the client behaviour
# TODO: use State Design Pattern (The State Design Pattern is a fully encapsulated, self-modifying Strategy Design Pattern)

require 'Map'
require 'Pathfinding'
#require 'enum'

KILL     = 1 # top level goal
PROTECT  = 2 # top level goal
MOVE     = 3

class Goal

   attr_accessor :thresold
   
   def initialize
      @cur_thres = 0
      @top_goals = [KILL,PROTECT]
   end

end

def distance(a,b)
   (a.x-b.x).abs + (a.y-b.y).abs
end

class Ant

   attr_accessor :goal
   
   # this function transform a goal into a move
   # it's the main "intelligent" function for an ant
   def get_move
      return nil if goal == nil
      case goal[0]
         when KILL
            e = goal[1] # mget the ennemy
            puts "our ennemy to kill: #{e}"
            dist = distance(self,e)
            if dist > 6
               # we have to move next to it
               # TODO: add_sub_goal
               a,b = find_best_way(e.x,e.y)
               return "Cb#{object_id}~"+[a,b].pack('cc')
            else
               return nil # TODO
            end
            return nil #"Cb#{object_id}~"+[x+3,y].pack('cc')
         end
   end

   # given x,y the case where we plan to go,
   # return a,b the case we have to go in this turn
   def find_best_way(x,y)
      # if x,y is an obstacle (could be an ennemy ant)
      # then find the nearest case
      # TODO
      [x,y] # temporary
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
