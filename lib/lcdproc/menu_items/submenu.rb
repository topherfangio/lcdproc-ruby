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
    
    class SubMenu < LCDProc::Menu
      include LCDProc::MenuItem
      LCDProc::MenuItem.add_support( :submenu, self )
      
      # Go ahead and add support so that users can pass :menu instead of :submenu to MenuItem.new
      LCDProc::MenuItem.add_support( :menu, self )
      
      @@submenu_item_count = 0
      
      # Creates a new SubMenu MenuItem object.
      #
      # The <tt>user_options</tt> will accept a hash of the following MenuItem options.
      #
      # * <tt>:id</tt> - The unique string that identifies this sub menu. Defaults to "SubMenuMenuItem_" + a sequence number.
      #
      # The <tt>lcdproc_options</tt> will accept a hash of the options to be passed to LCDd when creating or updating the sub menu.
      #
      # * <tt>:text</tt> - The text to be displayed on the LCD for this sub menu. Defaults to the id.
      def initialize( user_options = {}, lcdproc_options = {} )
        
        # Initialize the menu system with a nil client
        super( nil )
        
        @lcdproc_options = {}
        
        if user_options[:id].nil?
          @id = "SubMenuMenuItem_#{@@submenu_item_count}"
        else
          @id = user_options[:id]
        end
        
        @lcdproc_type = "menu"
        @lcdproc_event_type = "(enter|leave)"
        
        @lcdproc_options[:text] = "#{@id}"
        
        @lcdproc_options.update( lcdproc_options )
        
        [ :text ].each { |s| @lcdproc_options[s].quotify! }
        
        @@submenu_item_count += 1
      end
    end
    
  end
  
end
