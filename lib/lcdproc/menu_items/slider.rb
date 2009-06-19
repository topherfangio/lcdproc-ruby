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
  
  module MenuItems
    
    class Slider
      include LCDProc::MenuItem
      LCDProc::MenuItem.add_support( :slider, self )
      
      @@slider_item_count = 0
      
      # Creates a new Slider MenuItem object.
      #
      # The <tt>user_options</tt> will accept a hash of the following MenuItem options.
      #
      # * <tt>:id</tt> - The unique string that identifies this slider. Defaults to "SliderMenuItem_" + a sequence number.
      #
      # The <tt>lcdproc_options</tt> will accept a hash of the options to be passed to LCDd when creating or updating the slider.
      #
      # * <tt>:text</tt> - The text to be displayed on the LCD for this slider. Defaults to the id.
      # * <tt>:mintext</tt> - The text to be displayed at the far left (minimum) end of the slider. Defaults to "".
      # * <tt>:maxtext</tt> - The text to be displayed at the far left (maximum) end of the slider. Defaults to "".
      # * <tt>:minvalue</tt> - The minimum value that the slider should allow. Defaults to 0.
      # * <tt>:maxvalue</tt> - The maximum value that the slider should allow. Defaults to 100.
      # * <tt>:value</tt> - The initial starting value of the slider. Defaults to 0.
      # * <tt>:stepsize</tt> - The number by which the value is increased with every press of the increment or decrement key. Defaults to 1. A value of 0 means that it can only be controled from within the client program.
      def initialize( user_options = {}, lcdproc_options = {} )
        @lcdproc_options = {}
        
        if user_options[:id].nil?
          @id = "SliderMenuItem_#{@@slider_item_count}"
        else
          @id = user_options[:id]
        end
        
        @lcdproc_type = "slider"
        @lcdproc_event_type = "(plus|minus)"
        
        @lcdproc_options[:text] = "#{@id}"
        
        @lcdproc_options[:mintext] = ""
        @lcdproc_options[:maxtext] = ""
        @lcdproc_options[:minvalue] = 0
        @lcdproc_options[:maxvalue] = 100
        @lcdproc_options[:value] = 0
        @lcdproc_options[:stepsize] = 1
        
        @lcdproc_options.update( lcdproc_options )
        
        [ :text, :mintext, :maxtext ].each { |s| @lcdproc_options[s].quotify! }
        
        @@slider_item_count += 1
      end
    end
    
  end
  
end
