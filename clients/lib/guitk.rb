# Ant Battle GUI Toolkit
require 'gtk2'
require 'thread'

class GuiTk

   def initialize(map)
      @map = map
      Gtk.init
      window = Gtk::Window.new
      window.resize(505,505)
      window.title = 'Ant Battle Viewer'
      window.signal_connect("destroy") {
         Gtk.main_quit
         }
      @da = Gtk::DrawingArea.new
      window.add(@da)
      @da.signal_connect("expose_event") {
         paint
         }
      window.show_all
      @black = @da.style.copy
      @black.set_fg(Gtk::STATE_PRELIGHT, 0x0000, 0x0000, 0x0000)
      @red = @da.style.copy
      @red.set_fg(Gtk::STATE_PRELIGHT, 0x0000, 0xFFFF, 0x0000)
      @green = @da.style.copy
      @green.set_fg(Gtk::STATE_PRELIGHT, 0x0000, 0x0000, 0xFFFF)
      #@mutex = Mutex.new
      Thread.new {Gtk.main}
   end

   def paint
      #@mutex.synchronize {
         alloc = @da.allocation
         cw = alloc.width/20
         ch = alloc.height/20
         w = @da.window
         w.draw_rectangle(@da.style.white_gc, true, 0, 0, alloc.width, alloc.height)
         @da.set_style(@black)
         0.upto(20) { |i|
            w.draw_line(@da.style.fg_gc(@da.state),i*cw,0,i*cw,ch*20)
            w.draw_line(@da.style.fg_gc(@da.state),0,i*ch,cw*20,i*ch)
            }
         @da.set_style(@red)
         @map.allies_each { |ant|
            w.draw_rectangle(@da.style.fg_gc(@da.state), true, ant.x*cw+1, ant.y*ch+1, cw-1, ch-1 )
            }
         @da.set_style(@green)
         @da.style.set_fg(@da.state,65535,0,0)
         @map.ennemies_each { |ant|
            w.draw_rectangle(@da.style.fg_gc(@da.state), true, ant.x*cw+1, ant.y*ch+1, cw-1, ch-1 )
            }
         #}
   end
   
end

if __FILE__ == $0
require 'map'

map = Map.new
ant = Warrior.new
ant.x = ant.y = 5
map.add_object(ant)
GuiTk.new(map)

end
