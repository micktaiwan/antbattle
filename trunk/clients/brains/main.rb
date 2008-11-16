#!/usr/bin/env ruby

# set default values
ip = "127.0.0.1"
port = 5000
brain = 'random'
i = 0

# parse command line
while true
   arg = ARGV[i]
   break if arg == nil
   com = arg.split('=')
   case com[0].upcase
      when 'S'
         case com[1]
         when 'P' # public server
            ip = "82.238.147.130"
            port = 80
         else raise "Unknown server #{com[1]}"
         end
      when 'IP'
         ip = com[1]
      when 'PORT'
         port = com[1].to_i
      when 'BRAIN'
         brain = com[1]
      else raise "unknown key #{com[0]}"
   end
   i += 1
end

$LOAD_PATH << '../lib'
$LOAD_PATH << '../brains/Tests'

# create the colony and wake it up !
require 'Colony'
# load the brain
require "Brain#{brain.capitalize}"

c = Colony.new(ip,port)
c.run
