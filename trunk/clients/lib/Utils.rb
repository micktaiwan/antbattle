class String;

  def ord; self[0]; end; 
  def last; self[self.length-1].to_s; end; 
  def removelast; if (self.length>1); self[0..self.length-2]; else; return ""; end; end;
  def ischar;s=self.to_i;(s>="a".ord && s<="z".ord) || (s>="A".ord && s<="Z".ord) ? true : false; end;

end

class Fixnum;
 
  def last; self.to_s[self.to_s.length-1].to_s; end; 

end

PARAMSEP = "\e"
PARAMSEP_INT = 27

def translate_msg(pattern, packet)
 if (!packet.instance_of? Array)
   packet=packet.split
   end
  tmsg = []
  rv = []
  begin
  pattern.each_byte { |b|
     case b.chr
        when 'b'
           rv << packet.shift
        when 'B'
           rv << packet.shift.ord
        when 's'
           str = ""
           begin
              str += packet.shift
            end while (packet[0]!=PARAMSEP && packet[0]!=nil)
            packet.shift #on vire PARAMSEP
           rv << str
        when 'S'
           str = ""
           begin
              str += packet.shift.to_s
            end while (packet[0]!=PARAMSEP && packet[0]!=nil)
            packet.shift #on vire PARAMSEP
           rv << str.to_i               
        else puts "unknown format"
     end
     }
  tmsg << rv.clone
  rv = []
end while (packet.size>0)
tmsg
end

def translate_a_msg(pattern, packet)
 if (!packet.instance_of? Array)
   packet=packet.split
   end
  rv = []
  pattern.each_byte { |b|
     case b.chr
        when 'B'
           rv << packet.shift.ord
        when 'b'
           rv << packet.shift
        when 's'
           str = ""
           begin
              str += packet.shift.to_s
            end while (packet[0]!=PARAMSEP && packet[0]!=nil)
            packet.shift #on vire PARAMSEP
           rv << str
        when 'S'
           str = ""
           begin
              str += packet.shift.to_s
            end while (packet[0]!=PARAMSEP && packet[0]!=nil)
            packet.shift #on vire PARAMSEP
           rv << str.to_i               
        else puts "unknown format"
     end
     }
  rv
end

def get_param(m,n)
  #puts "get_param(#{m},#{n})"

  n = 1 if(n==0) # 1 based

  i    = 2 # skip the first 2 netmsg category chars
  ps   = 0 # paramsep counter
  size = m.size
  param = ''

  while(i < size)
     if(m[i]==PARAMSEP_INT)
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
           end while msg[i]!=PARAMSEP_INT
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
