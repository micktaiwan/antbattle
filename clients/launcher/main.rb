#!/usr/bin/env ruby

require 'gui'
require 'gui_client'

class AboutBox < Gtk::Dialog
    def initialize
        super("About",
                nil,
                Gtk::Dialog::MODAL,
                [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK])
        message = "Ant Battle Viewer.\nThat's all folks."
        hbox = Gtk::HBox.new
        hbox.add(Gtk::Image.new(Gtk::Stock::ABOUT, Gtk::IconSize::DIALOG))
        hbox.add(Gtk::Label.new(message))
        hbox.show_all
        self.vbox.add(hbox)
        self.show_all
    end
end



class Gui < GuiGlade


  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    super(path_or_data, root , domain , localedir, flag )
    sts("Starting...")
    @c = GuiClient.new('127.0.0.1',5000)
    @tree = @glade['tree']
    renderer = Gtk::CellRendererText.new
    @tree.append_column(Gtk::TreeViewColumn.new('Bot name',renderer,:text => 0))
    @tree.append_column(Gtk::TreeViewColumn.new('Version',renderer,:text => 1))
    #tree.append_column(Gtk::TreeViewColumn.new('Free text',renderer,:text => 2))
    @list = Gtk::ListStore.new(String,String)
    @tree.set_model(@list)
    @c.load_brains
    add_context_menu
    display_brains
    Gtk.timeout_add(10) { read }
    sts("Click connect to connect to the server")
    @red = Gdk::Color.new(255,0,0)
    puts @red.to_a
  end

  def add_context_menu
    menu = Gtk::Menu.new
    
    # Add to server queue
    i = Gtk::MenuItem.new("Add to queue")
    i.signal_connect("button_press_event") do |widget, event|
      @c.add_to_queue(@selected.to_s.to_i)
    end
    menu.append(i)
    
    # remove from server queue
    i = Gtk::MenuItem.new("Remove from queue")
    i.signal_connect("button_press_event") do |widget, event|
      puts "disconnect #{@selected}"
    end
    menu.append(i)
    
    menu.show_all
    @tree.add_events(Gdk::Event::BUTTON_PRESS_MASK)
    @tree.signal_connect("button_press_event") do |widget, event|
      s = @tree.selection.selected
      if (s != nil and event.button == 3)
        @selected = s
        menu.popup(nil, nil, event.button, event.time)
      end	
    end
  end


  def add_bot(name, version, text)
    n = @list.append
    n.set_value(0,name)
    n.set_value(1,version)
    #@tree.set_tooltip(text)
  end


    def display_brains
        @c.brains.each { |b|
            add_bot(b[:name], b[:version], b[:freetext])
        }
    end

    def draw
        area = @glade['field']
        #area.window.begin_paint(area)
        area.window.clear
        for i in (0..20)
          area.window.draw_line(area.style.fg_gc(area.state), 10, i*20+10, 410, i*20+10)
          area.window.draw_line(area.style.fg_gc(area.state), i*20+10, 10, i*20+10, 410)
        end
        gc = area.style.fg_gc(area.state)
        @c.map.hash.each_value { |obj|
          gc.set_foreground(@red)
          area.window.draw_rectangle(gc, true, obj.x*20+12, obj.y*20+12, 17, 17)
          #rv << obj if(obj.x==x and obj.y==y)
          }
        #area.window.end_paint
    end

    def read
        return true if not @c.connected?
        msg = @c.read
        return if msg == ""
        @c.parse(msg)
        @glade['field'].queue_draw
        true # needed for GTK
    end


    def on_main_destroy(widget)
        Gtk.main_quit
    end

    def on_field_expose_event(widget, arg0)
        draw
    end

    def on_startserver_clicked(widget)
        begin
            case @c.start_server
            when 0;
                sts("Started")
            else
                sts("Already started")
            end
        rescue
            sts($!)
        end
    end

    def on_connect_clicked
        begin
            sts("Connecting...")
            @c.connect
            sts("Connected")
        rescue
            sts($!)
        end
    end

    def on_about_clicked
        dlg = AboutBox.new
    end

    def sts str
        @glade['stsbar'].push(0, str)
    end


end

PROG_PATH = "gui.glade"
PROG_NAME = "AntBattle Launcher"
Gui.new(PROG_PATH, nil, PROG_NAME)
Gtk.main

