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
  
  class KeyEvent
    attr_reader :key, :block
    
    # Creates a new KeyEvent object. Note that this does not register it with a client, it only gives you a
    # clean object to pass around.
    #
    # * <tt>key</tt> - The key identifier. Valid values are "Escape", "Enter", "Up", "Down", "Left", or "Right".
    # * <tt>&block</tt> - The block that you would like to associate with this key.
    #
    # Example:
    #
    #   ke = KeyEvent.new( 'Enter' ) { puts 'Enter was pressed!' } 
    def self.new( key, &block )
      
      if block.nil?
        return nil
      else
        super( key, &block )
      end
      
    end
    
    
    def initialize( key, &block )
      @key = key
      @block = block
    end
    
  end
  
end
