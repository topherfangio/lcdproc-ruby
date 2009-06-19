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
  
  class Screen
    @@screen_count = 0
    
    attr_reader :key_events, :client, :id, :lcdproc_attributes, :priority, :widgets
    
    PRIORITIES = [ :hidden, :background, :info, :foreground, :alert, :input ]
    
    # Creates a new screen to which you may attach widgets.
    #
    # Example Usage:
    # 
    #   Screen.new( 'TestScreen' )
    def initialize( id = "Screen_" + @@screen_count.to_s )
      @id = id
      @client = nil
      @widgets = []
      @key_events = []
      @priority = :info
      
      @lcdproc_attributes = {}
      @lcdproc_attributes[:heartbeat] = :open
      
      @@screen_count += 1
    end
    
    
    # Add a widget to this screen
    def add_widget( widget )
      if @widgets.select{ |w| w == widget }.empty?
        
        if widget.attach_to( self )
          @widgets << widget
          
          if @client
            if widget.show
              return true
            else
              return false
            end
          else
            return true
          end
        else
          return false
        end
        
      else
        if @client
          @client.add_message( "Widget '#{widget.id}' is already added" )
        end
        
        return false
      end
    end
    
    
    # Sets the priority of this screen to "alert" status
    def alert!
      self.priority = :alert
    end
    
    
    # Attaches the screen to the requested client
    def attach_to( client )
      response = client.send_command( Command.new( "screen_add #{id.to_s}" ) )
      
      if response.successful?
        client.add_message( "Screen '#{self.id}' attached to client '#{client.name}'" )
        @client = client
        
        return true
      else
        client.add_message( "Error: Failed to attach screen '#{self.id}' to client '#{client.name}' (#{response.message} : #{response.successful?})" )
        return false
      end
    end
    
    
    # Detaches the screen from any client
    def detach
      if @client
        response = @client.send_command( Command.new( "screen_del #{self.id}" ) )
        
        if response.successful?
          @client.add_message( "Screen '#{self.id}' detached from client '#{@client.name}'" )
          @client = nil
          
          return true
        end
      else
        add_message "Error: Failed to detach screen '#{self.id}' from '#{@client.name}' (#{response.message})"
        return false
      end
    end
    
    
    # Turns on or off the screen's heartbeat
    #
    # * <tt>state</tt> - A symbol representing the state in which you wish the heartbeat to be. Valid values are <tt>:on</tt>, <tt>:off</tt> or <tt>:open</tt>.
    def heartbeat= state
      @lcdproc_attributes[:heartbeat] = state
      
      update_lcdproc_attribute( :heartbeat )
    end
    
    # Turns on or off the screen's backlight
    #
    # * <tt>state</tt> - A symbol representing the state in which you wish the backlight to be.Valid values are
    #    * :on - Always on.
    #    * :off - Always off.
    #    * :toggle - Toggle the current state.
    #    * :open - Use the client's setting.
    #    * :blink - Moderately striking backlight variation.
    #    * :flash - Very striking backlight variation.
    def backlight= state
      @lcdproc_attributes[:backlight] = state
      
      update_lcdproc_attribute( :backlight )
    end
    
    
    # Sets the priority status of this screen
    #
    # * <tt>other</tt> - The priority that you wish this screen to have. Accepted values are any integer (see LCDProc developer documentation for integer-priority mappings) or one of the following:
    #    * :hidden
    #    * :background
    #    * :info
    #    * :foreground
    #    * :alert
    #    * :input
    def priority=( other )
      if other.kind_of? Fixnum or ( other.kind_of? Symbol and Screen::PRIORITIES.inlcude? other )
        
        @priority = other
        
        if @client
          response = @client.send_command( Command.new( "screen_set #{@id} -priority #{@priority}" ) )
          
          if response.successful?
            return @priority
          else
            return nil
          end
        end
        
        return @priority
        
      end
      
      return nil
    end
    
    
    # Processed a particular key event
    def process_key( key )
      @key_events.select{ |ke| ke.key === key }.each do |ke|
        ke.block.call unless ke.block.nil?
      end
    end
    
    
    # Register a key event to be handled when the key is pressed on this screen. Note that you can register
    # the same key multiple times. All actions that are registered will be performed!
    #
    # Example:
    #
    #   c = Client.new
    #   s = Screen.new
    #   s.register_key_event( KeyEvent.new( 'Left' ) { puts "Left button was pressed!" } )
    def register_key_event( key_event )
      
      if key_event and @client and @client.valid_keys.include? key_event.key
        response = @client.send_command( Command.new( "client_add_key -shared #{key_event.key}" ) )
        
        if response.successful?
          @key_events << key_event
          return key_event
        end
      end
      
      return nil
    end
    
    
    # Removes a widget from the screen
    def remove_widget( widget )
      if @widgets.include? widget
        
        if widget.hide and widget.detach
          @widgets.delete( widget )
          return true
        else
          return false
        end
        
      else
        if @client
          @client.add_message( "Widget '#{widget.id}' is not attached to Screen '#{@id}'" )
        end
        
        return false
      end
    end
    
    
    # Unregisters a key event so that it will no longer be processed
    def unregister_key_event( key_event )
      if @key_events.include? key_event
        @key_events.delete key_event
        return key_event
      else
        return nil
      end
    end
    
    # Updates the current contents of the screen by iterating through it's widgets and calling each of their
    # update methods as well as making sure that they are displayed on the screen by calling their show method.
    def update
      if @client
        passed = true
        
        @widgets.each{ |widget| widget.show; passed = widget.update; if not passed then break end }
        
        if passed
          return true
        else
          return false
        end
      else
        return false
      end
    end
    
    
    # Updates a particular LCDProc attribute
    def update_lcdproc_attribute( attribute )
      if @client
        display = attribute.to_s.capitalize
        value = @lcdproc_attributes[attribute].to_s
        
        response = @client.send_command( Command.new( "screen_set #{@id} -#{attribute.to_s} #{value}" ) )
        
        if response.successful?
          @client.add_message( "#{display} set to '#{value}' for Screen '#{@id}'" )
          return true
        else
          @client.add_message( "Error: #{display} could not be set to '#{value}' for Screen '#{@id}' (#{response.message})" )
          return false
        end
      end
    end
    
  end
  
end
