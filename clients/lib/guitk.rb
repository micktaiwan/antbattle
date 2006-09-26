# Ant Battle GUI Toolkit
require 'gtk2'

class GuiTk

   def initialize
      Gtk.init
      window = Gtk::Window.new
      window.resize(505,505)
      window.title = 'Ant Battle Viewer'
      window.signal_connect("destroy") {
         Gtk.main_quit
         }
      da = Gtk::DrawingArea.new
      window.add(da)
      da.signal_connect("expose_event") {
         alloc = da.allocation
         cw = alloc.width/20
         ch = alloc.height/20
         0.upto(20) { |i|
            da.window.draw_line(da.style.fg_gc(da.state),i*cw,0,i*cw,ch*20)
            da.window.draw_line(da.style.fg_gc(da.state),0,i*ch,cw*20,i*ch)
            }
         }
      window.show_all
      Gtk.main
   end
   
end

GuiTk.new
