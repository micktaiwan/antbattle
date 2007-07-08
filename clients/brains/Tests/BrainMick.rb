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
      x = 1
      @map.allies_each(@id) { |a|
         #puts "each: #{a}"
         arr = a.get_move
         arr.each { |m| @tcp.formatsend(m) }
         #break if x == 3
         x += 1
         }
      @tcp.send("Ca")
      sleep(1)
   end
   
end
# La bonne strategie contre D4Killer c'est d'attaquer les coins
# donc la meilleure strategie c'est de choisir une cible qui offre le plus de points d'attaque
