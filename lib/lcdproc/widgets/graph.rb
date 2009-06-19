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
    
    class Graph
      include LCDProc::Widget
      LCDProc::Widget.add_support( :graph, self )
      
      attr_accessor :bars, :x, :y
      
      # Note that the lenght is not changeable after you have added a graph.
      attr_reader :length
      
      @@widget_count = 0
      
      
      # Creates a new Graph widget which can then be displayed anywhere on the screen.
      #
      # * <tt>id</tt> - A unique string which identifies this widget. Defaults to "GraphWidget_" + a sequence number.
      # * <tt>col</tt> - The beginning column in which you wish to display the graph on screen. Defaults to 1.
      # * <tt>row</tt> - The beginning row in which you wish to display the text on screen. Defaults to 1.
      # * <tt>length</tt> - The length of the graph (how many vertical bars to show). Defaults to 21 - x for a 20x4 screen.
      #
      # Example:
      #
      #   w = Graph.new
      #
      # or
      #
      #   w = Graph.new( 'Test', 'This is a graph', 1, 5, 10 )
      #
      # *NOTE*: The length of the graph is not changeable after it has been created
      def initialize( id = "GraphWidget_" + @@widget_count.to_s, col = 1, row = 1, length = 21 - col)
        if id.nil?
          id = "GraphWidget_#{@@widget_count}"
        end
        
        @id = id
        @type = :graph
        @screen = nil
        @visible = false
        
        @x = col
        @y = row
        @length = length
        
        @bars = []
        @length.times{ |i| @bars << VBar.new( "#{self.id}_Bar_#{i}", 1, @x + i, @y ) }
        
        @@widget_count += 1
      end
      
      
      # Actually sends the command to the LCDd server to remove the widget from the screen
      def hide
        
        # Only if we are visible, attempt to hide ourselves
        if @visible
          passed = true
          
          @bars.each do |bar|
            
            # If at any point we fail, bail out and return false
            if not bar.hide or not bar.detach
              passed = false
              break
            end
            
          end
          
          if passed
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
      
      
      # Actually sends the command to the LCDd server to add the widget to the screen
      def show
        
        # If we aren't already visible, attempt to make oursevles visible
        if not @visible
          commands = []
          passed = true
          
          @bars.each do |bar|
            
            # If at any point we fail, bail out and return false
            if not bar.attach_to( @screen ) or not bar.show( false )
              passed = false
              break
            end
            
          end
          
          @bars.each do |bar|
            commands << "widget_add #{@screen.id} #{bar.id} #{bar.type.to_s}"
          end
          
          response = @screen.client.send_command( Command.new( commands ) )
          
          if response.successful? and passed
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
      
      
      # Sends to command to the LCDd server to update the widget on screen
      def update
        
        if @screen
          commands = []
          
          @bars.each do |bar|
            commands << "widget_set #{@screen.id} #{bar.id} #{bar.x} #{bar.y} #{bar.height}"
          end
          
          response = @screen.client.send_command( Command.new( commands ) )
          
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
