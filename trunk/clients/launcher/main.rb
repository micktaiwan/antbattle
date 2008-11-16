#!/usr/bin/env ruby

require 'gui'
require 'launcher'

class Gui < GuiGlade

  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    super(path_or_data, root , domain , localedir, flag )
    @l = Launcher.new
    @glade['stsbar'].push(0,"Starting...")
    tree = @glade['tree']
    renderer = Gtk::CellRendererText.new
    tree.append_column(Gtk::TreeViewColumn.new('Bot name',renderer,:text => 0))
    tree.append_column(Gtk::TreeViewColumn.new('Version',renderer,:text => 1))
    @list = Gtk::ListStore.new(String,String)
    tree.set_model(@list)
    load_bots
  end

  def add_bot(name, version)
    n = @list.append
    n.set_value(0,name)
    n.set_value(1,version)
  end

  def load_bots
    @glade['stsbar'].push(0,"Loading bots...")
    add_bot('Random','1.0') # TODO: parse bots folder
    @glade['stsbar'].push(0,"Bots loaded")
  end
  
  def draw
    area = @glade['field']
    for i in (0..20) 
      area.window.draw_line(area.style.fg_gc(area.state),10,i*20+10,410,i*20+10)
      area.window.draw_line(area.style.fg_gc(area.state),i*20+10,10,i*20+10,410)
    end
  end
  
  def on_main_destroy(widget)
    Gtk.main_quit
  end
  def on_field_expose_event(widget, arg0)
    draw
  end
  def on_startserver_clicked(widget)
    @l.start_server
  end
  def on_startclients_clicked
    @l.start_clients
  end
  
end

PROG_PATH = "gui.glade"
PROG_NAME = "AntBattle Launcher"
Gui.new(PROG_PATH, nil, PROG_NAME)
Gtk.main

