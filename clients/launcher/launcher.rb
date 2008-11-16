# this class shall extract from the gui all necessary know-how
class Launcher

  def start_server
    r = %x[ps aux]
    if not r =~ /antbattleserver/
      puts "Launching..."
      system("../server/src/antbattleserver &") 
    else
      puts "already launched"
    end
  end
  
  def start_clients
  end
  
end

