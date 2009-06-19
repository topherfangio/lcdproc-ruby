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
    
    class Ring
      include LCDProc::MenuItem
      LCDProc::MenuItem.add_support( :ring, self )
      
      @@ring_item_count = 0
      
      # Creates a new Ring MenuItem object.
      #
      # The <tt>user_options</tt> will accept a hash of the following MenuItem options.
      #
      # * <tt>:id</tt> - The unique string that identifies this ring. Defaults to "RingMenuMenuItem_" + a sequence number.
      #
      # The <tt>lcdproc_options</tt> will accept a hash of the options to be passed to LCDd when creating or updating the ring.
      #
      # * <tt>:text</tt> - The text to be displayed on the LCD for this ring. Defaults to the id.
      # * <tt>:strings</tt> - A tab separated list of the strings to be displayed as options. Defaults to "Yes\tNo\tMaybe".
      # * <tt>:value</tt> - The index of the string to be displayed initially. Defaults to 0.
      def initialize( user_options = {}, lcdproc_options = {} )
        @lcdproc_options = {}
        
        if user_options[:id].nil?
          @id = "RingMenuItem_#{@@ring_item_count}"
        else
          @id = user_options[:id]
        end
        
        @lcdproc_type = "ring"
        @lcdproc_event_type = "update"
        
        @lcdproc_options[:text] = @id
        
        @lcdproc_options[:strings] = "Yes\tNo\tMaybe"
        @lcdproc_options[:value] = 0
        
        @lcdproc_options.update( lcdproc_options )
        
        [ :text, :strings ].each { |s| @lcdproc_options[s].quotify! }
        
        @@ring_item_count += 1
      end
    end
    
  end
  
end
