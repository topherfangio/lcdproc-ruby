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
    
    class Num
      include LCDProc::Widget
      LCDProc::Widget.add_support( :num, self )
      
      attr_accessor :x, :number
      
      @@widget_count = 0
      
      
      # Creates a new Num widget which can then be displayed anywhere on the screen.
      #
      # * <tt>:id</tt> - A unique string which identifies this widget. Defaults to "NumWidget_" + a sequence number.
      # * <tt>:num</tt> - The number that you wish to display on the screen. Default to 1.
      # * <tt>:col</tt> - The column in which you wish to display the num on screen. Defaults to 1.
      #
      # Example:
      #
      #   w = Num.new
      #
      # or
      #
      #   w = Num.new( 'Clock-Hour', 8, 1 )
      def initialize( id = "NumWidget_#{@@widget_count}", num = 1, col = 1 )
        if id.nil?
          id = "NumWidget_#{@@widget_count}"
        end
        
        @id = id
        @type = :num
        @screen = nil
        @visible = false
        
        @number = num
        @x = col
        
        @@widget_count += 1
      end
      
      
      # Sends to command to the LCDd server to update the widget on screen
      def update
        if @screen
          response = @screen.client.send_command( Command.new( "widget_set #{@screen.id} #{self.id} #{@x} #{@number}" ) )
          
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
