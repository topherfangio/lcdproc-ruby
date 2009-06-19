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


require 'lcdproc.rb'
include LCDProc

namespace :test do
  
  desc "Tests the registering and unregistering of keys."
  task :keys do
    puts "=== Running Keys Test ===\n"
    
    puts "Creating Client and Screen"
    c = Client.new
    s = Screen.new
    
    puts "Attaching Screen"
    c.attach( s )
    
    kel = KeyEvent.new( 'Left' ) { puts "Left Key Pressed" }
    ker = KeyEvent.new( 'Right' ) { puts "Right Key Pressed" } 
    keu = KeyEvent.new( 'Up' ) { puts "Up Key Pressed" } 
    ked = KeyEvent.new( 'Down' ) { puts "Down Key Pressed" } 
    keen = KeyEvent.new( 'Enter' ) { puts "Enter Key Pressed" } 
    kees = KeyEvent.new( 'Escape' ) { puts "Escape Key Pressed" } 
    
    puts "Registering new Key Event (Left Key) for 10 seconds..."
    s.register_key_event( kel )
    
    sleep( 10 )
    
    puts "Unregistering Key Event (Left Key)"
    s.unregister_key_event( kel )
    
    puts "Registering all events..."
    [ kel, ker, keu, ked, keen, kees ].each do |event|
      s.register_key_event( event )
    end
    
    sleep( 30 )
  end
  
end
