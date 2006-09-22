class AntClientList

   attr_reader :list

   def initialize
      @list = Hash.new
   end

   def add(c)
      @list[c.id] = c
   end
   
   def remove_id(id)
      @list.delete(id)
   end
   
   def get_id(id)
      @list[id]
   end
end

class AntClient
   attr_accessor :id, :type, :name, :version, :free_text, :ip

   def initialize
      @id = -1
      @type = -1
      @ip = ''
      @name = ''
      @version = ''
      @free_text = ''
   end

end
