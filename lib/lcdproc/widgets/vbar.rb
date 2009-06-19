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
  
  module Widgets
    
    class VBar
      include LCDProc::Widget
      LCDProc::Widget.add_support( :vbar, self )
      
      attr_accessor :x, :y, :height
      
      @@widget_count = 0
      
      
      # Creates a new VBar widget which can then be displayed anywhere on the screen.
      #
      # * <tt>:id</tt> - A unique string which identifies this widget. Defaults to "VBarWidget_" + a sequence number.
      # * <tt>:bar_height</tt> - The height of the bar. Default to 16 (half the height of a 20x4 character screen).
      # * <tt>:x_pos</tt> - The row in which the bar should be positioned. Defaults to 1.
      # * <tt>:y_pos</tt> - The column in which the bar should be positioned. Defaults to 1 (bottom of the screen).
      #
      # Example:
      #
      #   w = VBar.new
      #
      # or
      #
      #   w = VBar.new( 'TestBar', 32, 2, 4 )
      def initialize( id = "VBarWidget_#{@@widget_count}", bar_height = 16, x_pos = 1, y_pos = 1 )
        if id.nil?
          id = "VBarWidget_#{@@widget_count}"
        end
        
        @id = id
        @type = :vbar
        @screen = nil
        @visible = false
        
        @height = bar_height
        @x = x_pos
        @y = y_pos
        
        @old_height = nil
        @old_x = nil
        @old_y = nil
        
        @@widget_count += 1
      end
      
      
      # Sends to command to the LCDd server to update the widget on screen
      def update
        
        # Don't update unless something has actually changed
        if @x == @old_x and @y == @old_y and @height == @old_height
          return true
        end
        
        if @screen
          
          bar_height = @height
          
          if @height < 1
            bar_height = @height * 120
          end
          
          response = @screen.client.send_command( Command.new( "widget_set #{@screen.id} #{self.id} #{@x} #{@y} #{bar_height}" ) )
          
          if response.successful?
            @screen.client.add_message( "Widget '#{@id}' was successfully updated" )
            return true
          else
            @screen.client.add_message( "Error: Widget '#{@id}' was NOT successfully updated (#{response.message})" )
            return true
          end
        else
          @screen.client.add_message( "Error: Cannot update Widget '#{@id}' until it is attached to a screen" )
          return false
        end
      end
      
    end
    
  end
  
end
