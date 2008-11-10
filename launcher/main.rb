#!/usr/bin/env ruby

require 'gui'

class Gui < GuiGlade

  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    super(path_or_data, root , domain , localedir, flag )
    tree = @glade['tree']
    tree.append_column(Gtk::TreeViewColumn.new('Bot name'))
    @list = Gtk::ListStore.new(String)
    tree.set_model(@list)
   
    load_bots
  end

  def load_bots
    n = @list.append
    n.set_value(0,"yqsdo")
  end
  
  def on_main_destroy(widget)
    Gtk.main_quit
  end
  
end


PROG_PATH = "gui.glade"
PROG_NAME = "AntBattle Launcher"
Gui.new(PROG_PATH, nil, PROG_NAME)
Gtk.main

