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
    
    class IP
      include LCDProc::MenuItem
      LCDProc::MenuItem.add_support( :ip, self )
      
      @@ip_item_count = 0
      
      # Creates a new IP MenuItem object.
      #
      # The <tt>user_options</tt> will accept a hash of the following MenuItem options.
      #
      # * <tt>:id</tt> - The unique string that identifies this ip menu item. Defaults to "IPMenuItem_" + a sequence number.
      #
      # The <tt>lcdproc_options</tt> will accept a hash of the options to be passed to LCDd when creating or updating the ip.
      #
      # * <tt>:text</tt> - The text to be displayed on the LCD for this ip. Defaults to the id.
      # * <tt>:value</tt> - The value of the IP address. Defaults to "0.0.0.0".
      # * <tt>:v6</tt> - Whether or not the IP address should be in IPv6 format or not. Defaults to false.
      def initialize( user_options = {}, lcdproc_options = {} )
        @lcdproc_options = {}
        
        if user_options[:id].nil?
          @id = "IPMenuItem_#{@@ip_item_count}"
        else
          @id = user_options[:id]
        end
        
        @lcdproc_type = "ip"
        @lcdproc_event_type = "update"
        
        @lcdproc_options[:text] = "#{@id}"
        
        @lcdproc_options[:value] = "0.0.0.0"
        @lcdproc_options[:v6] = false
        
        @lcdproc_options.update( lcdproc_options )
        
        [ :text, :value ].each { |s| @lcdproc_options[s].quotify! }
        
        @@ip_item_count += 1
      end
    end
    
  end
  
end
