class Colony
   
   def init
      @progversion = "0.5"
      @progname = "ABCDE"
      @freetext = "Ant Battle Client Developper Example"
   end      

   def play
      @map.allies_each(@id) { |ant|
         #raise "play: having a dead ant" if(ant.life==0)
         rv = get_nearby_ennemies(ant)
         if(rv.size>0)
				puts "Attacking #{rv[0]}"
            @tcp.formatsend("Cc#{ant.object_id}~#{rv[0].object_id}"); # attack
            rv[0].life -= 5
         else
            # random coordinates
            x = ant.x + rand(7)-3
            y = ant.y + rand(7)-3
            if(x<0); x = 0; end
            if(y<0); y = 0; end
            if(x >= @map.w); x = @map.w-1; end
            if(y >= @map.h); y = @map.h-1; end
            puts "#{ant} going to #{x},#{y}"
            obj = @map.get_objects(x,y)
            next if(obj.size > 0) # if the case has an obstacle, just skip this move
            #TODO: something else than just skipping this move
            @tcp.formatsend("Cb#{ant.object_id}~"+[x,y].pack("cc")); # move it
            ant.x = x
            ant.y = y
          end
         }
      @tcp.send("Ca") # end of turn
      #sleep(3)
   end

   
   def get_nearby_ennemies(ant)
      rv = []
      @map.ennemies_each(@id) { |e|
         #puts e
         rv << e if (((ant.x-e.x).abs + (ant.y-e.y).abs) <= 1)
         #break if rv.size>0 # if you want to speed up the move, since we do not care about the others
         }
      rv
   end

end
