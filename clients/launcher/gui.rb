#!/usr/bin/env ruby
#
# This file is gererated by ruby-glade-create-template 1.1.4.
#
require 'libglade2'

class GuiGlade
  include GetText

  attr :glade
  
  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, "UTF-8")
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
    
  end
  
  def on_main_destroy(widget)
    puts "on_main_destroy() is not implemented yet."
  end
  def on_startserver_clicked(widget)
    puts "on_startserver_clicked() is not implemented yet."
  end
  def on_connect_clicked(widget)
    puts "on_connect_clicked() is not implemented yet."
  end
  def on_field_expose_event(widget, arg0)
    puts "on_field_expose_event() is not implemented yet."
  end
  def on_about_clicked(widget)
    puts "on_about_clicked() is not implemented yet."
  end
end

# Main program
if __FILE__ == $0
  # Set values as your own application. 
  PROG_PATH = "gui.glade"
  PROG_NAME = "YOUR_APPLICATION_NAME"
  GuiGlade.new(PROG_PATH, nil, PROG_NAME)
  Gtk.main
end
