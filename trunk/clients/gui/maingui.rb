require 'tgc.rb'
require 'tgcc.rb'

class Helper
  def Helper.showHelp
    puts "Usage: ruby maingui.rb host port\n\n"
    puts "Example:\n"
    puts "         ruby maingui.rb localhost 5000\n"
    puts "         ruby maingui.rb 82.238.147.130 80\n"
  end
end

if ARGV.length < 2
  Helper.showHelp
  puts "your inputs was : " + ARGV.join("-")
else
  ip,port=ARGV[0], ARGV[1]

$c = GuiClient.new(ip,port)
g=Graphic_renderer.new

$ant_client=Thread.new {
  begin
  $c.run
  rescue RuntimeError => s
  puts s.message
  puts "retrying to connect server in 5 seconds"
  $c.send_msg "Connection problem ;-("
  $c.send_msg "retrying to connect server in 5 seconds"
  $stdout.flush
  sleep 5
  retry
  rescue Exception => e
  puts "#{e.message} - (#{e.class})" << "\n" <<  (e.backtrace or []).join("\n")
  end}

$gui_client=Thread.new {
  begin
  g.start
  rescue SystemExit
  puts "Clean exit"
  exit(0)
  rescue Exception => e
  puts "Error rendering: #{ e.message } - (#{ e.class })" << "\n" <<  (e.backtrace or []).join("\n")
  end   }

$ant_client.join

 puts "tiny graphical client end"

end

