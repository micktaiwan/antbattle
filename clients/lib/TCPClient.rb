require 'socket'
require 'timeout'

class TCPClient

	def initialize(ip,port)
		@t = nil
    @ip = ip
    @port = port
	end

  def connect
    begin
      timeout(2) do
        @t = TCPSocket.new(@ip, @port)
      end
    rescue
      @t = nil
      raise
    end
  end
	
	def disconnect
		@t.close if(@t != nil)
	end

	def formatsend(msg)
		str = msg.gsub(/~/, [27].pack("c"))   
		send(str)
	end

	def send(str)
		s = str.size
		raise "msg too long" if s >= 256*256
		a = s/256
		b = s-a*256
		@t.print [a,b].pack("cc")
		@t.print str
	end
	
	def read
		raise "not connected" if @t == nil
		msg = ""
		
    readfds, writefds, exceptfds = select([@t], nil, nil, 0.1)
    return msg if !readfds

		len = @t.recv(2)
		len = len.unpack("n")[0]
    raise RuntimeError,"Error during reading socket" if len==nil
		if(len > 0)
			msg = @t.recv(len)
		end
		msg
	end

  def connected?
    return @t != nil
  end
  
  def shutdown
    @t.shutdown
  end
end
