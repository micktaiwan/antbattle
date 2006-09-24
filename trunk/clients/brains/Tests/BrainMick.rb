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
         m = a.get_move
         next if m == nil
         @tcp.formatsend(a.get_move)
         }
      @tcp.send("Ca")
   end
   
end
