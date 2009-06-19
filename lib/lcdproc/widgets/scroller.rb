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
    
    class Scroller
      include LCDProc::Widget
      LCDProc::Widget.add_support( :scroller, self )
      
      attr_accessor :left, :top, :right, :bottom, :direction, :speed, :text
      
      @@widget_count = 0
      
      
      # Creates a new Scroller widget which can then be displayed anywhere on the screen.
      #
      # * <tt>:id</tt> - A unique string which identifies this widget. Defaults to "ScrollerWidget_" + a sequence number.
      # * <tt>:left</tt> - The column in which to begin the scrolling text. Defaults to 1.
      # * <tt>:top</tt> - The row in which to begin the scrolling text. Defaults to 1.
      # * <tt>:right</tt> - The column in which to end the scrolling text. Defaults to 10 until attached to a screen, then defaults to the width of the screen.
      # * <tt>:bottom</tt> - The row in which to end the scrolling text. Defaults to 2 until attached to a screen, then defaults to the height of the screen.
      # * <tt>:direction</tt> - The direction that the text should scroll. One of "h" for horizontal, "v" for vertical, or "m" for marquee.
      # * <tt>:speed</tt> - The number of movements per rendering stroke (8 times per second).
      # * <tt>:text</tt> - The text that you wish to display on the screen. Default to "Hello, here is some really long text.". Note that if this string is shorter than the allotted width or height, no scrolling occurs.
      #
      # Example:
      #
      #   w = Scroller.new
      #
      # or
      #
      #   w = Scroller.new( 'TestScroller', 1, 1, 20, 4, "h", 1, "Some Scrolling Text")
      def initialize( id = "ScrollerWidget_#{@@widget_count}", left = 1, top = 1, right = 10, bottom = 2, direction = "h", speed = 1, text = "Hello, here is some really long text." )
        if id.nil?
          id = "ScrollerWidget_#{@@widget_count}"
        end
        
        @id = id
        @type = :scroller
        @screen = nil
        @visible = false
        
        @left = left
        @top = top
        @right = right
        @bottom = bottom
        @direction = direction
        @speed = speed
        @text = text
        
        @@widget_count += 1
      end
      
      
      # Allows a widget to be attached to a screen.
      def attach_to( screen )
        @right = screen.client.width
        @bottom = screen.client.height
        
        return super(screen )
      end
      
      # Sends to command to the LCDd server to update the widget on screen
      def update
        if @screen
          response = @screen.client.send_command( Command.new( "widget_set #{@screen.id} #{self.id} #{@left} #{@top} #{@right} #{@bottom} #{@direction} #{@speed} \"#{@text}\"" ) )
          
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
