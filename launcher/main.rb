#!/usr/bin/ruby
require 'gtk2'

class Launcher

   def initialize
      Gtk.init
      window = Gtk::Window.new
      window.resize(200,50)
      window.title = 'Ant Battle Launcher'
      window.signal_connect("destroy") {
         Gtk.main_quit
         }
      hpane = Gtk::HButtonBox.new
      hpane.spacing = 3
      window.add(hpane)
      sbtn = Gtk::Button.new('Launch Server')
      sbtn.signal_connect("pressed") {
         #~ system('gnome-terminal -e ls') #../server/src/antbattleserver
         #server = IO.popen('gnome-terminal ../server/src/antbattleserver')
         #p Process.waitpid(server.pid)
         #p $?
         system('ls')
         lsproc = IO.popen('ls')
         p Process.waitpid(lsproc.pid)
         p $?
         }
      hpane.add(sbtn)
      cbtn = Gtk::Button.new('Launch Client')
      hpane.add(cbtn)
      window.show_all   
      Gtk.main
   end

end

Launcher.new
