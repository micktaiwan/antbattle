class Colony
   
   def init
      @progversion = "0.2"
      @progname = "Straight"
   end      

   def play
      @map.allies_each { |ant|
         raise "play: having a dead ant" if(ant.life==0)
         # going straight to the ennemy
         x,y = ant.x, ant.y
         e = get_ennemies[0]
         return if e==[] or e==nil or e.x == -1
         xx = max_limit((e.x-x).abs,3)
         if(e.x>x)
            x += xx
         elsif(e.x<x)
            x -= xx
         end
         yy = max_limit((e.y-y).abs,3)
         yy -= xx;
         if(e.y>y+1)
            y += yy
         elsif(e.y<y-1)
            y -= yy
         end
         if(x<0); x = 0; end
         if(y<0); y = 0; end
         if(x >= @map.w); x = @map.w-1; end
         if(y >= @map.h); y = @map.h-1; end
         obj = @map.get_objects(x,y)
         if(obj.size == 0) # if the case has an obstacle, just skip this move
            @tcp.formatsend("Cb#{ant.object_id}~"+[x,y].pack("cc")); # move it
            wait_return("Cb"+ant.object_id.to_s)   
         end
         # Attack !
         rv = get_nearby_ennemies(ant)
         if(rv.size>0)
				puts "#{put_ant(ant)} attacks #{put_ant(rv[0])}"
            @tcp.formatsend("Cc#{ant.object_id}~#{rv[0].object_id}"); # attack
            wait_return("Cc"+ant.object_id.to_s)
         end
         }
      @tcp.send("Ca")
   end

   
   def get_nearby_ennemies(ant)
      e = get_ennemies()
      rv = []
      e.each { |e|
         rv << e if (((ant.x-e.x).abs + (ant.y-e.y).abs) <= 1)
         }
      rv
   end
   
   def get_ennemies()
      e = []
      @map.ennemies_each {|a| e << a}
      e.sort_by {|a| a.life} 
      e
   end

   def max_limit(a,b)
      return b if a > b
      return a
   end

   def put_ant(a)
      "#{a.object_id}(#{a.x},#{a.y})"
   end

   def wait_return(s)
      #puts "waiting #{s}"
      begin
         begin
            @msg = ""
            timeout(5) { @msg = @tcp.read }
         rescue Timeout::Error
            puts "time out"
         end
         #puts(sanitize(@msg))
         if(@msg != "")
            begin
               parse(@msg)
            rescue Exception => e
               puts "****** Parse msg error: #{ e.message } - (#{ e.class })" << "\n" << (e.backtrace or []).join("\n")
            end
         end
      end while(@msg[0,s.length]!=s && @msg[0,2]!="Ba" && @msg[0,2]!="Be")
   end
   
end
