#-------------------------------------------------------------------------------
# Copyright (c) 2008 Topher Fangio
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#-------------------------------------------------------------------------------


module LCDProc
  
  # MenuItem is a factory for creating new menu items and registering them with the client so that when the
  # menu item's event is processed, it can call the associated block.
  module MenuItem
    attr_reader :id, :is_hidden, :lcdproc_type, :lcdproc_event_type, :next, :parent_menu, :previous, :text
    attr_accessor :lcdproc_options
    @supported_types = {}
    
    def MenuItem.new( type = :string, options = {}, lcdproc_options = {} )
      if @supported_types.include? type
        menu_item = @supported_types[ type ].new( options, lcdproc_options )
        
        return menu_item
      else
        return nil
      end
      
    end
    
    # Allows a particular type of menu item to inform the MenuItem module (which is a MenuItem factory) that it is
    # able to support a particular type of menu item.
    def MenuItem.add_support( type, menu_item_class )
      @supported_types[type] = menu_item_class
    end
    
    
    # Returns an array of symbols listing the supported types of menu items.
    def MenuItem.supported_types
      @supported_types.keys
    end
    
    
    # Set's whether or not the menu item is hidden.
    #
    # * <tt>value</tt> - True or false
    #
    # Example:
    #
    #   m = MenuItem.new( :action )
    #   m.is_hidden = true
    #
    def is_hidden= value
      # If we have a client, go ahead and send the command; otherwise, just set the value.
      if @parent_menu and @parent_menu.client
        response = @parent_menu.client.send_command( Command.new( "menu_set_item \"#{@parent_menu}\" \"#{@id}\" -is_hidden #{value}" ) )
        
        if response.successful?
          @is_hidden = value
        else
          return nil
        end
      else
        @is_hidden = value
      end
    end
    
    
    # Returns a string representation of the lcdproc_options that can be sent directly to LCDd.
    def lcdproc_options_as_string
      options_as_lcdproc = []
      @lcdproc_options.each{ |key,value| options_as_lcdproc << "-#{key} #{value}" }
      options_as_lcdproc.join(" ")
    end
    
    def text= value
      # If we have a client, go ahead and send the command; otherwise, just set the value.
      if @parent_menu and @parent_menu.client
        response = @parent_menu.client.send_command( Command.new( "menu_set_item \"#{@parent_menu}\" \"#{@id}\" -text #{value}" ) )
        
        if response.successful?
          @text = value
        else
          return nil
        end
      else
        @text = value
      end
    end
  end
  
end
