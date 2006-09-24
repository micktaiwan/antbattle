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

class Map

   def has_obstacle(n)
      #puts pnode(n)
      #@hash.each{|a| puts a}
      arr = @hash.find_all {|a| a[1].x == n[0] and a[1].y == n[1]}
      return true if(arr.size > 0)
      return nil
   end

end

class Ant

   attr_accessor :goal
   
   # this function transform a goal into a move
   # it's the main "intelligent" function for an ant
   def get_move
      #puts "get_move for #{self}"
      return [] if goal == nil
      rv = []
      case goal[0]
         when KILL
            e = goal[1] # get the ennemy
            puts "I am #{self}"
            puts "goal = kill this enneny: #{e}"
            dist = distance(self,e)
            if dist > 3
               # by doing this we are finding subgoals
               # TODO: add_sub_goal ?
               a,b = find_best_way(e.x,e.y)# we have to move next to it
               return rv if a == nil
               puts "Our move is (#{[a,b].join(',')})"
               self.x,self.y = a,b
               rv << "Cb#{object_id}~"+[a,b].pack('cc')
               return rv # do not return if we can attack at the same round
            else
               puts "Attack"
               rv << "Cc#{e.object_id}"
            end
      end # case
      rv
   end

   # given x,y the case where we plan to go,
   # return a,b the case we have to go in this turn
   def find_best_way(xx,yy)
      pf = Pathfinder.new($map)
      pf.ignore_obs_target = true
      path = pf.find([x,y],[xx,yy])
      #puts ppath(path)
      if path == nil # no path
         return [nil,nil]
      else
         if(path.size > 6)
            x = 6 
         else
            x = path.size-2 # 0 based, minus one, so -2
            puts ppath(path)
         end
         return path[x][0]
      end
   end
   
end


class Colony

   # set the top goal for each ant
   def set_goals
      # doing simple: give the goal "kill this ant" for each ant
      $map = @map # FIXME
      x = nil
      @map.ennemies_each { |e|
         x = e
         break
         }
      raise "oops" if x == nil
      i = 0
      @map.allies_each{ |a|
         a.goal = [KILL, x]
         i += 1
         break if i == 4
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
