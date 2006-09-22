#module Utils
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
