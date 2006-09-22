#module Utils

   PARAMSEP = 27

   def get_param(m,n)
      #puts "get_param(#{m},#{n})"
   
      n = 1 if(n==0) # 1 based

      i    = 2 # skip the first 2 netmsg category chars
      ps   = 0 # paramsep counter
      size = m.size
      param = ''

      while(i < size)
         if(m[i]==PARAMSEP)
            ps+= 1   # we just passed a parameter
            i += 1    # skip the PARAMSEP
            return param if(i==size)
            next
         end
         return param if(ps==n)  # that was it, param contains the last param
         param += m[i].chr if(ps==n-1) # we are reading it
         i+=1
      end       

      return param # we read all the string
   end

   def get_param_from(m,n)
      #puts "get_param_from(#{m},#{n})"
      msg = "xx"+m[n..(m.size-1)]
      get_param(msg,1)
   end
   
   def parse_msg(msg,format)
      rv = []
      i = 0
      format.each_byte { |b|
         case b.chr
            when 'b'
               rv << msg[i]
            when 's'
               str = ""
               begin
                  str += msg[i].chr
                  i += 1
               end while msg[i]!=PARAMSEP
               rv << str
            else puts "unknown format"
         end
         i += 1
         }
      rv
   end
   
   def sanitize(msg)
      rv = ""
      s = msg.size
      i = 0
      while(i < s)
         if (msg[i] == 27)
            rv += '/' 
         elsif (msg[i] < 32)
            rv += '-' 
         else
            rv += msg[i].chr
         end
         i += 1
      end
      rv
   end
   
   def deep_copy(obj)
      Marshal.load(Marshal.dump(obj))
   end
   
   def log level,indent,str
      return if level > 1
      indent.times {print " "}
      puts str
   end
#end

#puts Utils.instance_methods
#puts get_param("test"+[PARAMSEP].pack("c")+"version",2)

#p = [PARAMSEP].pack("c")
#msg = [1,2].pack("cc")+"01"+p+"02"+p+[3,4].pack("cc")

#arr = parse_msg(msg,"bbssbb")
#puts arr

#puts get_param_from(msg,5)
