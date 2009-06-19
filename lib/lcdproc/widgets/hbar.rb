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
    
    class HBar
      include LCDProc::Widget
      LCDProc::Widget.add_support( :hbar, self )
      
      attr_accessor :x, :y, :length
      
      @@widget_count = 0
      
      
      # Creates a new HBar widget which can then be displayed anywhere on the screen.
      #
      # * <tt>:id</tt> - A unique string which identifies this widget. Defaults to "HBarWidget_" + a sequence number.
      # * <tt>:bar_length</tt> - The length of the bar. Default to 120 (fills a 20x4 character screen).
      # * <tt>:row</tt> - The row in which the bar should be positioned. Defaults to 1.
      # * <tt>:col</tt> - The column in which the bar should be positioned. Defaults to 1.
      #
      # Example:
      #
      #   w = HBar.new
      #
      # or
      #
      #   w = HBar.new( 'TestBar', 15, 1, 5 )
      def initialize( id = "HBarWidget_#{@@widget_count}", bar_length = 120, row = 1, col = 1 )
        if id.nil?
          id = "HBarWidget_#{@@widget_count}"
        end
        
        @id = id
        @type = :hbar
        @screen = nil
        @visible = false
        
        @length = bar_length
        @x = row
        @y = col
        
        @@widget_count += 1
      end
      
      
      # Sends to command to the LCDd server to update the widget on screen
      def update
        if @screen
          
          bar_length = @length
          
          if @length < 1
            bar_length = @length * 120
          end
          
          response = @screen.client.send_command( Command.new( "widget_set #{@screen.id} #{self.id} #{@x} #{@y} \"#{bar_length}\"" ) )
          
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
