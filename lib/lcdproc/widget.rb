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
  
  # *NOTE*: You may only have one (1) type of the following per screen: hbar, vbar or num. They currently conflict
  # with each other and will not draw properly. You *MAY* have as many of each type per screen as you like. For
  # instance, you *MAY* have twenty (20) vertical bars per screen or four (4) horizontal bars on a screen, but
  # you cannot mix and match!
  
  module Widget
    attr_reader :id, :screen, :type, :visible
    @supported_types = {}
    
    # Finds the first widget that is of type _type_ and returns a new instance of it.
    #
    # * <tt>type</tt> - A symbol representing the type of widget you wish to create.
    # * <tt>id</tt> - A unique string by which you can indentify the widget. Defaults to the widget type +
    # "Widget_" + a sequence number
    #
    # Example:
    #
    #   w = Widget.new( :string, 'Test' )
    def Widget.new( type = :string, id = nil  )
      if @supported_types.include? type
        @supported_types[ type ].new( id )
      else
        return nil
      end
    end
    
    # Returns an array of symbols listing the supported types of widgets.
    def Widget.supported_types
      @supported_types.keys
    end
    
    # Allows a particular type of widget to inform the Widget module (which is a Widget factory) that it is
    # able to support a particular type of widget.
    def Widget.add_support( type, widget_class )
      @supported_types[type] = widget_class
    end
    
    # Allows a widget to be attached to a screen.
    def attach_to( screen )
      @screen = screen
      
      return true
    end
    
    # Allows a widget to be dettached from a screen.
    def detach
      attach_to nil
    end
    
    
    # Sends the command to the LCDd server to remove the widget from the screen unless you
    # pass false, in which case it does everything but send the command
    def hide( send_command = true )
      
      if not send_command
        @visible = false
        @screen.client.add_message( "Widget '#{@id}' is now hidden" )
        return true
      end
      
      # Only if we are visible, attempt to hide ourselves
      if @visible
        response = @screen.client.send_command( Command.new( "widget_del #{@screen.id} #{self.id}" ) )
        
        if response.successful?
          @visible = false
          @screen.client.add_message( "Widget '#{@id}' is now hidden" )
          return true
        else
          @visible = true
          @screen.client.add_message( "Error: Widget '#{@id}' could NOT be hidden (#{response.message})" )
          return false
        end
      else
        return true
      end
      
    end
    
    # Sends the command to the LCDd server to show the widget on the screen unless you
    # pass false, in which case it does everything but send the command
    def show( send_command = true )
      
      if not send_command
        @visible = true
        @screen.client.add_message( "Widget '#{@id}' is now visible" )
        return true
      end
      
      # If we aren't already visible, attempt to make oursevles visible
      if not @visible
        response = @screen.client.send_command( Command.new( "widget_add #{@screen.id} #{self.id} #{@type.to_s}" ) )
        
        if response.successful?
          @visible = true
          @screen.client.add_message( "Widget '#{@id}' is now visible" )
          
          self.update
          
          return true
        else
          @visible = false
          @screen.client.add_message( "Error: Widget '#{@id}' could NOT be displayed (#{response.message})" )
          return false
        end
      else
        return true
      end
    end
    
    
  end
  
end
