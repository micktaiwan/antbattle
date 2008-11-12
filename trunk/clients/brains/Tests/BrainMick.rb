require 'Utils'
require 'goals'
   
class Colony
   
   def init
      @progversion = "0.1"
      @progname = "Submarine Prick"
      @freetext = "Find the anagram :)"
      @goals = []
   end      

   def play
      set_goals
      @map.allies_each(@id) { |a|
         puts "each: #{a}"
         arr = a.get_move
         arr.each { |m| @tcp.formatsend(m) }
         #break
         }
      @tcp.send("Ca")
      #
      sleep(1)
   end
   
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
# La bonne strategie contre D4Killer c'est d'attaquer les coins
# donc la meilleure strategie c'est de choisir une cible qui offre le plus de points d'attaque
