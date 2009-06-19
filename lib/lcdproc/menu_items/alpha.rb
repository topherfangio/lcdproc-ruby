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
    
    class Alpha
      include LCDProc::MenuItem
      LCDProc::MenuItem.add_support( :alpha, self )
      
      @@alpha_item_count = 0
      
      # Creates a new Alpha MenuItem object.
      #
      # The <tt>user_options</tt> will accept a hash of the following MenuItem options.
      #
      # * <tt>:id</tt> - The unique string that identifies this alpha. Defaults to "AlphaMenuItem_" + a sequence number.
      #
      # The <tt>lcdproc_options</tt> will accept a hash of the options to be passed to LCDd when creating or updating the alpha.
      #
      # * <tt>:text</tt> - The text to be displayed on the LCD for this alpha. Defaults to the id.
      # * <tt>:value</tt> - The string that you wish to be able to modify. Defaults to "AString".
      # * <tt>:password_char</tt> - If you wish that the text entered be a password, you may set this char to appear instead of the actual letters. Defaults to "" (off).
      # * <tt>:minlength</tt> - The minimum allowed length of the string. Defaults to 0.
      # * <tt>:maxlength</tt> - The maximum allowed length of the string. Defaults to 10.
      # * <tt>:allow_caps</tt> - Whether or not the string is allowed to have capital letters. Defaults to true.
      # * <tt>:allow_noncaps</tt> - ??? Not quite sure about this one, I believe it is whether or not you may have lower case letters. Defaults to false (this is the puzzling part).
      # * <tt>:allow_numbers</tt> - Whether or not the string is allowed to have numbers. Defaults to false.
      # * <tt>:allow_extras</tt> - A string containing any other characters that you wish to be allowed. Defaults to "".
      def initialize( user_options = {}, lcdproc_options = {} )
        @lcdproc_options = {}
        
        if user_options[:id].nil?
          @id = "AlphaMenuItem_#{@@alpha_item_count}"
        else
          @id = user_options[:id]
        end
        
        @lcdproc_type = "alpha"
        @lcdproc_event_type = "update"
        
        @lcdproc_options[:text] = "#{@id}"
        @lcdproc_options[:value] = "AString"
        @lcdproc_options[:password_char] = ""
        @lcdproc_options[:minlength] = 0
        @lcdproc_options[:maxlength] = 10
        @lcdproc_options[:allow_caps] = true
        @lcdproc_options[:allow_noncaps] = false
        @lcdproc_options[:allow_numbers] = false
        
        @lcdproc_options.update( lcdproc_options )
        
        [ :text, :value, :password_char ].each { |s| @lcdproc_options[s].quotify! }
        
        @@alpha_item_count += 1
      end
    end
    
  end
  
end
