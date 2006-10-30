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
      @map.allies_each { |a|
         #puts "each: #{a}"
         arr = a.get_move
         arr.each { |m| @tcp.formatsend(m) }
         #break if x == 3
         x += 1
         }
      @tcp.send("Ca")
   end
   
end
