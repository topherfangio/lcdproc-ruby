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

def my_cool_slider_callback( value )
  puts "Current Slider Value: #{value}"
end

namespace :test do
  
  desc "Runs a test that creates a variety menus attached to a client."
  task :menus do
    puts "=== Running Menus Test ===\n"
    
    c = Client.new( :name => 'MenuTest' )
    
    action_nothing = c.menu.add_item( MenuItem.new( :action, { :id => 'nothing' }, { :text => 'I Do Nothing' } ) )
    
    ring_manual = MenuItem.new( :ring, { :id => 'Ring' }, { :text => 'ManualRing', :strings => [ 'Yes', 'No', 'Whatever' ].join('\t') } )
    c.menu.add_item( ring_manual )
    c.register_menu_event( MenuEvent.new( ring_manual ) { |response| puts "Ring: " + response.split(' ')[-1].to_s } )
    
    checkbox_boom = c.menu.add_item( MenuItem.new( :checkbox, { :id => 'Boom'},  { :text => 'Boom', :allow_gray => true } ) ) { |response| puts response.split(' ')[-1] }
    
    slider = c.menu.add_item( MenuItem.new( :slider, { :id => 'Fluidity' } ) ) { |r| my_cool_slider_callback( r.split(' ')[-1] ) }
    
    alpha = c.menu.add_item( MenuItem.new( :alpha, { :id => 'AlphaText' }, { :value => "Abstract" } ) ) { |r| puts "Alpha value updated to #{r.split(' ')[-1] }" }
    
    ip = c.menu.add_item( MenuItem.new( :ip, { :id => 'LocalIP' } ) ) { |r| puts "IP: #{r.split(' ')[-1]}" }
    
    submenu = c.menu.add_item( MenuItem.new( :submenu, { :id => "SubMenu", :text => "Sub Menu" } ) )
    submenu_action_noperrs = submenu.add_item( MenuItem.new( :action, :id => 'Noperrs' ) ) { |r| puts r.split(' ')[-1] }
    submenu_submenu = submenu.add_item( MenuItem.new( :submenu, { :id => 'Subber' }, :text => 'Subber' ) ) { |r| puts r.split(' ')[-1] }
    submenu_submenu_checkbox = submenu_submenu.add_item( MenuItem.new( :checkbox, { :id => 'Checkers' }, :text => 'Check Me' ) ) { |r| puts r.split(' ')[-1] }
    
    
    #puts "\nCommands: " + c.commands.collect{ |cmd| cmd.message }.inspect
    #puts "\nMessages: " + c.messages.inspect
    #puts "\nMenu Items: " + c.menu.items.inspect
    #puts "\nMenu Events: " + c.menu_events.inspect
    
    
    sleep_time = 500
    
    puts "Sleeping for #{sleep_time} seconds..."
    sleep sleep_time
  end
  
end
