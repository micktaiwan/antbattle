require "opengl"
require "glut"
require  "tgcc.rb"
require  "GLUtils.rb"

class Graphic_renderer

COULEURS=[[ 1.0, 0.0, 0.0, 0.0 ],[ 0.0, 1.0, 0.0, 0.0 ],[ 0.0, 0.0, 1.0, 0.0 ]]

def pputs(x,y=1)
if @debug==nil
  @debug=1
  end
  if y>=@debug
    puts x
    $stdout.flush
  end
end  
      
def init_materials
    mat_ambient = [ 0.0, 0.0, 0.0, 1.0 ];
    mat_diffuse = [ 0.4, 0.4, 0.4, 1.0 ];
    mat_specular = [ 1.0, 1.0, 1.0, 1.0 ];
    mat_shininess = [ 15.0 ];
    light_ambient = [ 0.0, 0.0, 0.0, 1.0 ];
    light_diffuse = [ 1.0, 1.0, 1.0, 1.0 ];
    light_specular = [ 1.0, 1.0, 1.0, 1.0 ];
    lmodel_ambient = [ 0.2, 0.2, 0.2, 1.0 ];

    GL.Material(GL::FRONT, GL::AMBIENT, mat_ambient);
    GL.Material(GL::FRONT, GL::DIFFUSE, mat_diffuse);
    GL.Material(GL::FRONT, GL::SPECULAR, mat_specular);
    GL.Material(GL::FRONT, GL::SHININESS, *mat_shininess);
    GL.Light(GL::LIGHT0, GL::AMBIENT, light_ambient);
    GL.Light(GL::LIGHT0, GL::DIFFUSE, light_diffuse);
    GL.Light(GL::LIGHT0, GL::SPECULAR, light_specular);
    GL.LightModel(GL::LIGHT_MODEL_AMBIENT, lmodel_ambient);

    GL.Enable(GL::LIGHTING);
    GL.Enable(GL::LIGHT0);
    GL.DepthFunc(GL::LESS);
    GL.Enable(GL::DEPTH_TEST);
end

def puts_fps
    @frames = 0 if not defined? @frames
    @t0 = 0 if not defined? @t0

    @frames += 1
    t = GLUT.Get(GLUT::ELAPSED_TIME)
    if t - @t0 >= 5000
      seconds = (t - @t0) / 1000.0
      fps = @frames / seconds
      printf("%d frames in %6.3f seconds = %6.3f FPS <*> ",@frames, seconds, fps)
      @t0, @frames = t, 0
      puts @j.to_s + " " + @k.to_s + " " + @l.to_s + "<*>" + @x.to_s + " " + @y.to_s + " " + @z.to_s
    end
end
  

def txts(m1,x=20,y=20,color= [ 1.0, 0.5, 0.5])

@gl_txt.draw(){
  GL::ShadeModel(GL::FLAT);
  GL.Disable(GL::LIGHTING);
  GL.Disable(GL::LIGHT0);
  GL.Disable(GL::DEPTH_TEST);
  
  GL::MatrixMode(GL::PROJECTION);
  GL::LoadIdentity();
  GL::Ortho(0.0, @w, 0.0, @h, 0.0, -1.0);
  GL::MatrixMode(GL::MODELVIEW);
}

  ml=m1.split("\n");
    GL.Color(color);
    m=ml.pop
    y=y;
    while (m!=nil)
        GL.RasterPos(x, y);
        @t.printString(m);
        y=y+20;
        m=ml.pop
    end

end


def puts_unit(x,y,idf,life)
    a=x-@nx/2
    b=y-@ny/2
    GL.Translate(a,b, 0.0);
    @gl_units.draw{ GLUT.SolidSphere(0.5, 6, 6);   }
    GL.Translate(-a,-b, 0.0);
end
  
def puts_units
if @units!=nil
 for i in 0..@units.length-1  
    if @units[i]!=nil
      GL.Material(GL::FRONT, GL::DIFFUSE,  COULEURS[i]);
      for u in @units[i]
        puts_unit(u.x,u.y,u.object_id,u.life)
      end
    end
 end
  else
    txts("no unit")
end
end

def puts_resource(x,y)
GL.PushMatrix();  
position = [x, y, 2, 0.0];
GL.Material(GL::FRONT, GL::DIFFUSE,  [1,1,1,1 ]);
GL::Light(GL::LIGHT0, GL::POSITION, position);    
GL.Translate(x-@nx/2, y-@ny/2,0.3);
GLUT.SolidTeapot(0.5);   # draw unit
GL.PopMatrix();
end

def puts_resources
#~ puts_resource(10,10)
   for u in @units[i]
      puts_unit(u.x,u.y,u.object_id,u.life)
   end
end

def draw_world
@gl_world.draw() {
  @nx.times do |y|
    @ny.times do |x|
    GL.PushMatrix();
    GL.Translate(x-@nx/2, y-@ny/2, 0.0);
    GL.Scale(0.5,0.5,1);
    drawplane();
    GL.PopMatrix();
    end
  end
  }     
end


def process_msg(t)
     msg= $c.get_msg
     if (msg!="")
       @game_info_svg += msg
       @game_info +=msg
         b=@game_info.split("\n");
         if b.length >30;
           @game_info=b[-30,30].join("\n") + "\n"; 
         end              
       @gl_txts.release
       end
     if (t-@last_seen)/20>20
       @game_info +=" \n"
       @last_seen+=400
     end
end
   
def puts_txts
if @game_info==nil then @game_info=" \n" end
if @game_info_svg==nil then @game_info_svg ="Message logs:\n" end

@last_seen=GLUT.Get(GLUT::ELAPSED_TIME) if !defined? @last_seen
t=GLUT.Get(GLUT::ELAPSED_TIME)

if $c!=nil && $c.map!=nil
      if @chat_enable==true
        txts(  "CHAT: " + @input_chat, 10,@h-20,[1,1,1])
        end
      #players name
      if $c.get_player_info!=nil && $c.get_player_info!=""
        i=0
        $c.get_player_info.split("\n").each {|a|
        txts(a, 200 * i +2, 2, COULEURS[i])
        i=i+1
        }
      end
     #main text
     process_msg(t)
       
    end
@gl_txt.draw_if_undef{txts("")}
@gl_txts.draw{txts(@game_info,20,20+(t-@last_seen)/20)}

@gl_txts.release

end



def chat
GL.PushMatrix();
txts("123aazert");
GL.PopMatrix();
end

def init_draw_view
GL.Viewport(0, 0, @w, @h);
GL.MatrixMode(GL::PROJECTION);
GL.LoadIdentity();
GLU.Perspective(10,  @w.to_f/@h.to_f, 1.0, 800.0);
GLU.LookAt(@cx,@cy,@xcz,@tx,@ty,@tz, 0.0, 1.0, 0.0);
end

def init_display_f
@display = Proc.new {
pputs "display",0
@display_fct.call #suivant ce que l'on veut afficher !
}
@display_message_logs= Proc.new {
GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT);
@last_seen=GLUT.Get(GLUT::ELAPSED_TIME) if !defined? @last_seen
t=GLUT.Get(GLUT::ELAPSED_TIME)
process_msg(t)

teapot
txts(@game_info_svg);
GLUT.SwapBuffers()
}

@display_help = Proc.new {
GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT);
teapot
txts("H HELP\n\nx/X y/Y z/Z TRANSLATIONS\nj/J k/K l/L ROTATIONS\n" +
       "f/F ADJUST TRANS/ROT FACTOR\n"+
       "wheel button ROTATIONS\n\n"+
       "c CHAT\n" +
       "m MESSAGE LOGS\n" +
       "i INFORMATION ABOUT CONNECTED CLIENTS\n" +
       "a ABOUT\n\n"+
       "ESC EXIT\n");
GLUT.SwapBuffers()
}
@display_about = Proc.new {
GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
txts("TINY GRAPHICAL CLIENT\nCODED USING LA RACHE\n")
GLUT.SwapBuffers()
}

@display_information= Proc.new {
GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT);
txts($c.get_client_info);
GLUT.SwapBuffers()
}

@display_game = Proc.new {
@gl_inits.draw() {
      GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT);
      GL::ShadeModel(GL::SMOOTH);
      init_materials;
      init_draw_view;
      }

    infinite_light = [ 1.0, 1.0, 1.0, 0.0 ];
    local_light = [ 1.0, 1.0, 1.0, 1.0 ];
    
GL.PushMatrix();
#~ Deplacement dans le monde en 3d    
    GL.Translate(@x,@y,@z);
    GL.Rotate(@j.to_f,1,0,0)
    GL.Rotate(@k.to_f,0,1,0)
    GL.Rotate(@l.to_f,0,0,1)

    GL.Light(GL::LIGHT0, GL::POSITION, local_light);

    draw_world #~ Affichage de la grille

    local_light = [ 1.0, -1.0, 1.0, 1.0 ];
    GL.Light(GL::LIGHT0, GL::POSITION, local_light);    
    puts_units 
    puts_resources #~ Affichage des resources
puts_fps

GL.PopMatrix
puts_txts

GLUT.SwapBuffers


Thread.pass
}

@reshape = Proc.new {|w, h|
pputs "reshape",0

@gl_world.release
@gl_inits.release
@gl_txts.release
@gl_txt.release
@gl_players.release
@gl_units.release

h=0.01 if h==0
@w=w
@h=h
init_draw_view
}

@keyboard = proc {|key, x, y|
pputs "keyboard",0

@display_fct=@display_game
 
if @chat_enable
  if (key>31) && (key<128);@input_chat+=key.chr; end
   case (key)
      when 8;  @input_chat=@input_chat.removelast;
      when 13;   $c.send_chat(@input_chat);@input_chat="";@chat_enable=false;
      when 27;   @input_chat="";@chat_enable=false;key=""
end
end
  
if !@chat_enable
   case (key)
      when 'c'[0];@chat_enable=true;
      when 'C'[0];@chat_enable=true;
      when 'X'[0];@x = @x - @f ;
      when 'y'[0];@y = @y + @f ;
      when 'Y'[0];@y = @y - @f ;
      when 'z'[0];@z = @z + @f ;
      when 'Z'[0];@z = @z - @f ;
      when 'f'[0];if @f<100; @f = @f  * 2;end
      when 'F'[0];if @f>0.01; @f = @f / 2;end
      when 'j'[0];@j = @j + @f ;
      when 'J'[0];@j = @j - @f ;
      when 'k'[0];@k = @k + @f ;
      when 'K'[0];@k = @k - @f ;
      when 'l'[0];@l = @l + @f ;
      when 'L'[0];@l = @l- @f ;
      when 'M'[0];@display_fct=@display_message_logs
      when 'm'[0];@game_info=@game_info_svg
      when 'h'[0];@display_fct=@display_help
      when 'i'[0];@display_fct=@display_information 
      when 'a'[0];@display_fct=@display_about   
      when 27
      $c.destroy if $c!=nil
      exit
    end
  end
}


@mouse = Proc.new {|button, state, x, y|
pputs "mouse",0

@display_fct=@display_game

@mouse_state = state
@mouse_button = button

   case button
      when GLUT::LEFT_BUTTON
         if (state == GLUT::DOWN)
            @a=x;
            @b=y;
          end
         if (state == GLUT::UP)
           if (@a==nil ||@b==nil) then @a=x;@b=y; end
            dx=x-@a;
            dy=y-@b;
            if ((100-@z)!=0) 
              @x=@x+dx/(100-@z)
            end
            if ((100-@z)!=0) 
              @y=@y-dy/(100-@z)
            end            
          end
      when GLUT::MIDDLE_BUTTON          
              @x0, @y0 = x, y
   end
}

@menu = Proc.new {|value|
pputs "menu",0


@display_fct=@display_game

   case (value)
      when 1
          @xcz=(@ny+1)*6
          @cx=@cy=@tx=@ty=@tz=0
          @j=@k=@l=0
          @gl_inits.release
      when 10
          @display_fct=@display_about
      when 11
          @display_fct=@display_help
      when 12
          @chat_enable=true          
      when 0
      init_cam();
    end

}

@timer = Proc.new {|x|
pputs "timer",0

if $c!=nil && $c.map!=nil
#take size change into account
  if (!defined? @real_nx) || (!defined? @real_ny) || (@real_nx!=$c.map.w) || (@real_ny!=$c.map.h)
    @real_nx=$c.map.w
    @real_ny=$c.map.h    
    init_cam
    @units=[]; #defintion d'objet call_list
    @gl_world.release
    @gl_inits.release
  end
  
  
$c.map.joueurs.size.times {|j|
      @units[j]=$c.map.joueur(j)
      }       
    end

GLUT.TimerFunc(300,@timer,0);
}

@idle = Proc.new {
pputs "idle",0
GLUT.PostRedisplay()
sleep(0.03);
 }

@motion = Proc.new {|x, y|
pputs "motion",0
if @x0==nil then @x0=x end
if @y0==nil then @y0=y end
if @mouse_button == GLUT::MIDDLE_BUTTON && @mouse_state == GLUT::DOWN then
  @l += @x0 - x
  @j += @y0 - y
  end
 @x0, @y0 = x, y
}

@display_fct=@display_game

end

def init_cam
@x=@y=@z=0
@j=@k=@l=0
@j=-60
@l=-45

@f =1
@w=600
@h=400


@nx=1;
@ny=1;

@nx=@real_nx if defined? @real_nx
@ny=@real_ny if defined? @real_ny

@cx=@cy=@tx=@ty=@tz=0
@xcz=(@ny+1)*6

end

def initialize
pputs "initialize main opengl windows"

init_cam

@units=[];

#defintion d'objet call_list
@gl_world=GL_call_list.new
@gl_inits=GL_call_list.new
@gl_txt=GL_call_list.new
@gl_txts=GL_call_list.new
@gl_players=GL_call_list.new
@gl_units=GL_call_list.new
@input_chat=""

    GLUT.Init
    GLUT.InitDisplayMode(GLUT::DOUBLE | GLUT::RGB | GLUT::DEPTH);
    GLUT.InitWindowSize(@w, @h);
    GLUT.InitWindowPosition(100, 100);
    GLUT.CreateWindow('Tiny Graphical Client');
    
    init_display_f();

    GLUT.ReshapeFunc(@reshape);
    GLUT.KeyboardFunc(@keyboard);
    GLUT.MouseFunc(@mouse);
    GLUT.DisplayFunc(@display);
    GLUT.IdleFunc(@idle);
    GLUT.MotionFunc(@motion);
    GLUT.TimerFunc(400,@timer,0);
    
    GLUT.CreateMenu(@menu);
    GLUT.AddMenuEntry("3D view", 0);
    GLUT.AddMenuEntry("2D view", 1);
    GLUT.AddMenuEntry("Chat", 12);
    GLUT.AddMenuEntry("About", 10);
    GLUT.AddMenuEntry("Help", 11);
    GLUT.AttachMenu(GLUT::RIGHT_BUTTON);

    @t=Txt.new;
    
    pputs "Open GL initialized"
end

def start
    pputs "starting MainLoop"
    GLUT.MainLoop()
  end
  
end

