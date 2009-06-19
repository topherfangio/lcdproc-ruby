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
  
  class Client
    # The maximum number of messages allowed to stay in memory. This works much like a circular array with the
    # oldest messages being overwritten.
    MAX_MESSAGES = 512
    
    # The number of milliseconds to wait before processing new responses.
    RESPONSE_PROCESS_TIME = 25
    
    # Whether or not debugging output should be displayed.
    DEBUG = false
    
    # The number of LCDProc-Ruby clients currently connected to the server.
    @@client_count = 0
    
    attr_reader :key_events, :commands, :name, :menu_events, :messages, :response_queue, :screens, :width, :height, :cell_width, :cell_height
    attr_accessor :menu
    
    # Create a new client.
    # 
    # If <tt>:host</tt> is left blank, it will attempt to connect to "_localhost_" on port <i>13666</i>. You may also
    # specify another port through <tt>:port</tt>.
    # 
    # * <tt>:host</tt> - The host to which the client should attempt to connect. Defaults to "localhost".
    # * <tt>:port</tt> - The port on which the client should attempt to connect. Defaults to 13666.
    # * <tt>:name</tt> - The name that should be associated with this client. Defaults to "Client_" + a sequence number.
    #
    # Example:
    #
    #   my_client = Client.new
    #
    # or
    #
    #   my_client = Client.new( :host => "my.remote-host.com", :port => 13667, :name => 'MyGamingRig' )
    def initialize( user_options = {} )
      if self.respond_to?( :before_initialize ) then self.send( :before_initialize, user_options ) end
      
      @messages = []
      @commands = []
      @response_queue = []
      @screens = []
      @menu_events = []
      @global_key_events = []
      @current_screen = nil
      
      options = {}
      
      options[:host] = "localhost"
      options[:port] = 13666
      options[:name] = "Client_#{@@client_count}"
      
      # Update our defaults with anything that they passed in
      options.update( user_options )
      
      @daemon_socket = connect( options[:host], options[:port] )
      
      if @daemon_socket.nil?
        return nil
      end
      
      @thread = Thread.new { while true do sleep( RESPONSE_PROCESS_TIME.to_f / 1000.0 ); process_responses end }
    
    response = send_command( Command.new( "hello" ) )
    response = response.message.split(' ')
    
    @version      = response[2]
    @protocol     = response[4]
    @width        = response[7]
    @height       = response[9]
    @cell_width   = response[11]
    @cell_height  = response[13]
    
    @menu = Menu.new( self )
    
    response = send_command( Command.new( "info" ) )
    driver_info = response.message
    
    LCDProc::Devices.find_all_that_drive( driver_info ).each do |device|
      LCDProc::Client.send( :include, device )
    end
    
    @name = options[:name]
    
    response = send_command( Command.new( "client_set -name #{@name}" ) )
    
    @@client_count += 1
    
    if self.respond_to?( :after_initialize ) then self.send( :after_initialize, options ) end
  end
  
  
  # Adds a message to the client's message list. Used seperately from the responses returned by
  # the LCDd server. If there are more than MAX_MESSAGES, the oldest message will be removed from
  # the stack.
  #
  # * msg - The message to be added.
  #
  # Example:
  #
  #   client.add_message( "Woah Man!!! Something is wrong!!!" )
  def add_message( msg )
    @messages.unshift( msg )
    
    if @messages.length > MAX_MESSAGES
      @messages.pop
    end
  end
  
  
  # Attaches a screen to this client.
  #
  # * screen - Any screen which contains any number of widgets.
  #
  # Example:
  #
  #	  s = Screen.new( 'MyTestScreen' )
  #   client.attach( s )
  #
  # or
  #
  #   client.attach( Screen.new( 'MyTestScreen' ) )
  def attach( screen )
    
    if @screens.select{ |s| s.id == screen.id }.empty?
      if screen.attach_to( self )
        @screens << screen
        screen.update
        return true
      else
        return false
      end
    else
      return false
    end
    
  end
  
  
  # Detaches a screen from the client but leaves it in memory so that it may later be attached to another
  # client or re-attached to this client.
  #
  # * <tt>screen</tt> - Any screen currently attached to this client.
  #
  # Example:
  #
  #   client.detach( 'TestScreen' )
  def detach( screen )
    if @screens.include? screen
      
      if screen.detach
        @screens.delete( screen )
        return true
      else
        return false
      end
      
    else
      add_message "Error: Screen '#{screen.id}' is not attached to client '#{self.name}'"
      return false
    end
  end
  
  
  # Returns the last received message from the @messages array (internally more like a circular array).
  #
  # Example:
  #
  #   puts client.message
  def message
    @messages.first
  end
  
  
  # Sets the name of the client
  #
  # * <tt>name</tt> - The new name of the client
  # 
  # Example:
  #
  #   client.name = 'MyGreatClient'
  def name= name
    response = send_command( Command.new( "client_set -name #{name}" ) )
    
    if response.successful?
      @name = name
      
      return @name
    else
      error = "Error: Failed to set client's name to '#{name}'\n\n#{response.message}".gsub( /\n/, "\n    " )
      add_message error
      
      raise InvalidCommand, error
    end
  end
  
  
  # Register a new button event for the client to process and reserves the key.
  def register_key_event( key_event )
    
    if key_event and valid_keys.include? key_event.key
      response = send_command( Command.new( "client_add_key -exclusively #{key_event.key}" ) )
      
      if response.successful?
        @global_key_events << key_event
        return key_event
      end
    end
    
    return nil
  end
  
  
  # Register a new menu event for the client to process
  def register_menu_event( menu_event )
    
    if menu_event
      @menu_events << menu_event
      return menu_event
    else
      return nil
    end
    
  end
  
  
  # Sends a command to the server and returns a Response object. This is generally used for internal
  # purposes, but has been opened to the public API in case LCDProc changes it's behaviour or adds new
  # features. You should *NOT* use this to bypass the default behaviour such as setting a client's name.
  #
  # * <tt>command</tt> - The Command object that you wish to send to the server.
  #
  # Example:
  #
  # 	client.send_command( Command.new( 'info' ) )
  def send_command( command )
    
    puts "Command: " + command.message unless not DEBUG
    if command.message.kind_of? String
      
      @daemon_socket.write( command.message )
      @commands << command
      
      # NOTE: This extra get_response is here because LCDd will get confused if sent two messages very
      # quickly when trying to add menu items to a menu. Hopefully it will be removed when they have their
      # commands queued properly.
      if command.message =~ /^menu_add_item/
        r1 = get_response
        
        if r1.message =~ /^success/
          get_response
        end
        
        return r1
      else
        return get_response
      end
      
    elsif command.message.kind_of? Array
      
      @daemon_socket.write( command.message.join("\n") )
      @commands << command
      return get_response( command.message.length )
      
    end
  end
  
  
  # Unregisters a button event from the client
  def unregister_key_event( key_event )
    if @global_key_events.include? key_event
      @global_key_events.delete key_event
      return key_event
    else
      return nil
    end
  end
  
  
  # Register a new menu event for the client to process
  def unregister_menu_event( menu_event )
    
    if @menu_events.include? menu_event
      @menu_events.delete( menu_event )
      return menu_event
    else
      return nil
    end
  end
  
  
  # Returns the keys that may be registered for the client
  def valid_keys
    if VALID_KEYS
      VALID_KEYS
    else
      []
    end
  end
  
  
  private
  # Connects this client to a remote (or local) LCDd server.
  #
  # * <tt>:host</tt> - The remote host to which you wish to connect. Defaults to <i>"localhost"</i>.
  # * <tt>:port</tt> - The port on which the TCP socket should be opened. Defaults to <i>13666</i>.
  def connect( host, port )
    begin
      daemon_socket = TCPSocket.new( host, port )
    rescue Errno::ECONNREFUSED
      add_message "Connection to '#{host}':#{port} was refused"
    end
    
    return daemon_socket
  end
  
  
  # Blocks until a message is entered into the response queue, creates a new Response object
  # and returns it to the requester.
  def get_response( number_of_responses = 1 )
    
    responses = []
    
    1.upto( number_of_responses ) do |i|
      response = @response_queue.pop
      
      while response.nil?
        Thread.pass
        
        response = @response_queue.pop
      end
      
      puts "Q: #{@response_queue}, #{response}" unless not DEBUG
      
      responses << response
    end
    
    if responses.length == 1
      puts "returning one response" unless not DEBUG
      
      return Response.new( responses[0] )
    else
      puts "returning multiple response: #{responses.length}" unless not DEBUG
      
      return Response.new( responses )
    end
  end
  
  
  # Controls processing the responses received from the LCDd server. This includes
  # <tt>listen</tt> and <tt>ignore</tt> messages as well as button presses and responses to
  # commands. Takes no arguments.
  #
  # This should be called via a thread in the client at least twice every second (currently
  # set to fifty (50) times a second).
  def process_responses
    data = @daemon_socket.recv( 1024 )
    
    puts "Data: " + data unless not DEBUG
    array = data.split( "\n" )
    
    puts "Array: #{array.inspect}" unless not DEBUG
    
    array.each do |response|
      puts "response: #{response} about to be processed" unless not DEBUG
      
      # Process the listen event
      if response =~ /^listen .*$/
        
        @current_screen = @screens.find{ |s| s.id == response.split(' ').last }
        puts " ! processing listen..." unless not DEBUG
        
        
        
        # Process the ignore event
      elsif response =~ /^ignore .*$/
        
        puts " ! processing ignore..." unless not DEBUG
        
        
        
        # Process menu events
      elsif response =~ /^menuevent .*$/
        
        puts " ! processing a menu event: #{response}" unless not DEBUG
        
        @menu_events.each do |me|
          if response =~ /^menuevent #{me.menu_item.lcdproc_event_type} #{me.menu_item.id}/
            if me.block
              me.block.call( response )
            end
          end
        end
        
        
        
        # Process key events
      elsif response =~ /^key .*$/
        key = response.split(' ').last
        
        puts "Processing key #{key} in Client" unless not DEBUG
        
        @global_key_events.each do |gbe|
          if ( key == gbe.key ) and ( gbe.block )
            gbe.block.call
          end
        end
        
        @current_screen.process_key( key )
        
        
        
        # Otherwise stick it in the queue
      else
        # If we don't know how to process it, assume that it is a response to a command
        @response_queue << response
        puts "response: #{response} added to queue" unless not DEBUG
      end
    end
    
  end
  
end

end
