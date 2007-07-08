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
      return [] if goal == nil or goal == []
      while(1)
         rv = []
         g = goal.shift
         return [] if g == nil
         puts g.join('---')
         case g[0]
            when KILL
               e = g[1] # get the ennemy
               if(not $map.exists?(e) or e.life<=0)
                  puts 'this ant does not exists anymore or is dead, next goal'
                  next 
               end
               
               dist = distance(self,e)
               #puts "I am #{self}"
               #puts "goal: kill this enneny: #{e}"
               i = 0
               if dist > 1 # move
                  # by doing this we are finding subgoals
                  # TODO: add_sub_goal ?

                  path = find_best_way(e.x,e.y)# we have to move next to it
                  #puts ppath(path)
                  if path==nil
                     # TODO: no path, find something else to do
                     puts 'no path ! , next goal'
                     next
                  end
                  
                  # we have a path to it
                  # so now we have to move smartly
                  # if we are at 3 cases, we can move and attack
                  # more than that we have to move at 4 cases and wait the next turn
                  # TODO: do not wait at a position where we can be attacked
                  if(path.size-2 <= 3) # minus two because the path include our case
                     i = path.size-2  # 0 based minus one, so -2 
                     #puts 's1'
                  elsif(path.size-2 >= 6) # we are far away
                     i = 6
                     #puts 's2'
                  else
                     i = (path.size-2)
                     #puts 's3'
                  end
                  #puts i
                  #sleep(1)
                  if i <= 0
                     puts "i <= 0 (#{i}), #{ppath(path)}"
                     sleep(5)
                  else
                     a,b = path[i][0]
                     #puts "I am moving to (#{[a,b].join(',')})"
                     self.x,self.y = a,b
                     rv << "Cb#{object_id}~"+[a,b].pack('cc')
                     #puts x
                  end
               end
               return rv if i > 3 # return if we can not attack at the same round
               #puts i
               dist = distance(self,e)
               if dist == 1
                  puts 'Attack'
                  rv << "Cc#{object_id}~#{e.object_id}"
                  e.life -= 5
               end
               return rv
         else
            puts 'unknown goal, next goal'
         end # case
      end #while
      puts "no goal ? find something else to do !"
      rv
   end

   # given x,y the case where we plan to go,
   # return a,b the case we have to go in this turn
   def find_best_way(xx,yy)
      pf = Pathfinder.new($map)
      pf.ignore_obs_target = true # permit to calculate a path to a case with an ennemy on it
      path = pf.find([x,y],[xx,yy])
   end
   
end


class Colony

   # set the goals for each ant
   def set_goals
      $map = @map # FIXME
      # doing simple: give the goal "kill the nearest ant" for each ant
      @map.allies_each(@id) { |ant|
         ant.goal = []
         # calculate distances
         dist = []
         @map.ennemies_each(@id) { |e|
            dist << [e,distance(ant,e)]
            }
         dist = dist.sort_by {|couple| couple[1]}
         # add the goal "Kill this ant" for each ennemy
         dist.each { |d|
            ant.goal << [KILL, d[0]]
            }
         # print information
         puts "#{ant} goals:"
         ant.goal.each { |g|
            puts "   "+g.join(': ')            
            }
         #break   
         }
      return

      # get state of the game
      #calculate each top goals weight
      #@top_goals.each { |g|
      #   get_weight(g)
      #   }
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
