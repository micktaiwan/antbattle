class Colony
   
   def init
      @progversion = "0.1"
      @progname = "Straight"
   end      

   def play
      @allies.each { |ant|
         raise "play: having a dead ant" if(ant.life==0)
         rv = get_nearby_ennemies(ant)
         if(rv.size>0)
				@tcp.formatsend("Cc#{ant.object_id}~#{rv[0].object_id}"); # attack
            rv[0].life -= 5
         else
            # going straight to the ennemy
            x,y = ant.x, ant.y
            ex, ey = get_ennemy
            return if ex == -1
            xx = 1
            if(ex>x)
               x += xx
            elsif(ex<x)
               x -= xx
            end
            yy = 1
            if(ey>y)
               y += yy
            elsif(ey<y)
               y -= yy
            end
            if(x<0); x = 0; end
            if(y<0); y = 0; end
            if(x >= @map.w); x = @map.w-1; end
            if(y >= @map.h); y = @map.h-1; end
            @tcp.formatsend("Cb#{ant.object_id}~"+[x,y].pack("cc")); # move it
          end
         }
      @tcp.send("Ca")
   end

   
   def get_nearby_ennemies(ant)
      rv = []
      @ennemies.each { |e|
         rv << e if (((ant.x-e.x).abs + (ant.y-e.y).abs) <= 1) and e.life > 0 # should not test that if the ant is not in the map anymore
         }
      rv
   end
   
   def get_ennemy()
      @ennemies.each { |e|
         return [e.x,e.y] if(e.life > 0) 
         }
      [-1,-1]
   end

   def max_limit(a,b)
      return b if a > b
      return a
   end
   
end
