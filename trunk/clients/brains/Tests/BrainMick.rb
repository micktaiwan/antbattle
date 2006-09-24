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
      @map.allies_each { |a|
         #puts "each: #{a}"
         arr = a.get_move
         arr.each { |m| @tcp.formatsend(m) }
         }
      @tcp.send("Ca")
   end
   
end
