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
  
  class MenuItemStore
    attr_accessor :menu_item, :menu_event, :added_to_screen
    
    def initialize( menu_item, menu_event, added_to_screen )
      @menu_item = menu_item
      @menu_event = menu_event
      @added_to_screen = added_to_screen
    end
    
  end
  
  class Menu
    attr_reader :client, :id, :items
    attr_accessor :parent
    
    @@menu_count = 0
    
    # Create a new Menu object optionally attached to a client. Note that if you would like to create
    # a sub menu which can be attached to a menu, you should use LCDProc::MenuItems::Submenu.
    #
    # Note that when a client is created, this function is called and and it becomes the default client's menu
    #
    # * <tt>client</tt> - The client to which you wish this menu to be attached. Defaults to nil
    def initialize( client = nil )
      @id = "".quotify
      @parent = nil
      @client = client
      @stored_items = []
    end
    
    
    # Adds the specified menu item to this menu. Returns the menu item that was added.
    #
    # * <tt>menu_item</tt> - The menu item that you wish to add
    # * <tt>&block</tt> - You may optionally pass a block to this menthod to register a menu event with the client
    #
    # Example:
    #
    #   c = Client.new
    #   a = c.menu.add_item( MenuItem.new( :action, :id => 'AnAction' ) ) { |response| puts "AnAction was pressed!!!" }
    #
    #   # a now contains the action menu item
    def add_item( menu_item, &block )
      
      # This slight hack allows for sub menus to correctly know to whom they belong
      if menu_item.respond_to? :parent=
        menu_item.send( :parent=, self )
      end
      
      @stored_items << MenuItemStore.new( menu_item, MenuEvent.new( menu_item, &block ), false )
      
      update
      
      return menu_item
    end
    
    
    # Attaches this menu to a particular client. Note that this will detach this menu from any existing clients.
    #
    # * <tt>client</tt> - The client to which you wish to be attached. Defaults to nil.
    # * <tt>should_update</tt> - Whether or not we should go ahead and display all of our items on the screen. Defaults to true.
    #
    # Example:
    #
    #   c1 = Client.new
    #   c2 = Client.new
    #   c2.detach
    #
    #   c1.menu.attach_to( c2 )
    def attach_to( client = nil, should_update = true )
      
      self.detach
      
      @client = client
      
      if should_update
        self.update
      end
    end
    
    
    # Detaches this menu from the current client. Note that if this fails, it still detaches the client, so
    # you might have extraneous menu items lying around (but you shouldn't so long as you don't bypass the
    # add_item method somehow...)
    def detach
      errors = []
      
      @stored_items.select{ |si| si.added_to_screen == true }.each do |visible_stored_item|
        menu_item = visible_stored_item.menu_item
        
        response = client.send_command( Command.new( "menu_del_item #{@id} #{menu_item.id.quotify}" ) )
        
        if not response.successful?
          errors << true
        end
      end
      
      # Make sure that we don't still think that any are visible on the screen
      @stored_items.each { |si| si.added_to_screen = false }
      
      @client = nil
      
      return errors.length == 0
    end
    
    
    # Adds any existing, but not currently added, menu items to the screen (including sub menus and their items).
    # This may be called to ensure that all items are displayed in the menu and is called whenever a menu item
    # is added to a menu. This technically allows you to create a menu object that is not attached to a
    # client, later attach it to a client and then call the update method to display the menu and it's items
    # on screen. 
    #
    # Example
    #
    #   c = Client.new
    #   c.menu.update
    def update
      
      if @client
        client = @client
      else
        parent_menu = @parent
        
        while not parent_menu.nil? and parent_menu.client.nil?
          parent_menu = parent_menu.parent
        end
        
        client = parent_menu.client unless parent_menu.nil? or parent_menu.client.nil?
      end
      
      if client
        
        @stored_items.select{ |mis| mis.added_to_screen == false }.each do |stored_item|
          menu_item = stored_item.menu_item
          
          response = client.send_command( Command.new( "menu_add_item #{@id} #{menu_item.id.quotify} #{menu_item.lcdproc_type} #{menu_item.lcdproc_options_as_string}" ) )
          
          if not response.successful?
            return nil
          else
            stored_item.added_to_screen = true
          end
          
          if not stored_item.menu_event.nil?
            client.register_menu_event( stored_item.menu_event )
          end
          
          if menu_item.respond_to? :update
            menu_item.send( :update )
          end
          
        end
        
      end
      
    end
    
  end
  
end
