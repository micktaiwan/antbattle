
# parse command line

ip = "127.0.0.1"
port = 5000
@@brain = 'random'
i = 0
while true
   arg = ARGV[i]
   break if arg == nil
   com = arg.split('=')
   case com[0].upcase
      when 'S'
         case com[1]
         when 'M'
            ip = "82.238.147.130"
            port = 80
         else raise "Unknown server #{com[1]}"
         end
      when 'IP'
         ip = com[1]
      when 'PORT'
         port = com[1].to_i
      when 'BRAIN'
         @@brain = com[1]
      else raise "unknown key #{com[0]}"
   end
   i += 1
end


# load brains

$LOAD_PATH << '../lib'
$LOAD_PATH << '../brains/Tests'

case @@brain
   when  'minmax'
      require 'BrainMinimax'
   when 'random'
      require 'BrainRandom'
   when 's2'
      require 'BrainStraight'
   when 's1'
      require 'BrainStraight_0.1'
   when 'mick'
      require 'BrainMick'
   else
      raise "Unknown brain: #{@@brain}"
end

# create the colony and wake it up !

require 'Colony'
c = Colony.new(ip,port)
c.run
