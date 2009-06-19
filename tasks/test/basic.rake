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
  
  desc "Runs a basic test that creates a client, attaches a screen and adds some widgets."
  task :basic do
    puts "=== Running Basic Test ===\n"
    puts "Creating client..."
    c = Client.new
    
    puts "Creating screens..."
    s1 = Screen.new
    s2 = Screen.new
    s3 = Screen.new
    s4 = Screen.new
    
    puts "Attaching screens..."
    c.attach( s1 )
    c.attach( s2 )
    c.attach( s3 )
    c.attach( s4 )
    
    puts "Creating widgets..."
    w1 = Widget.new( :string )
    w2 = Widget.new( :hbar )
    w3 = Widget.new( :vbar )
    w4 = Widget.new( :graph )
    w5 = Widget.new( :num )
    
    puts "Setting up widgets..."
    w2.y = rand( 2 ) + 2
    
    w3.x = rand( 20 )
    w3.height = rand( 22 ) + 10
    
    w4.bars.each{ |bar| bar.height = rand( 22 ) + 10 }
    
    puts "Adding widgets to screens..."
    s1.add_widget( w1 )
    s1.add_widget( w2 )
    
    s2.add_widget( w3 )
    
    s3.add_widget( w4 )
    
    s4.add_widget( w5 )
    
    #puts c.commands.collect{ |cmd| cmd.message }
    #puts c.messages
    
    puts "Sleeping for 10 seconds..."
    sleep 10
  end
  
end
