#!/usr/bin/env ruby

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


# Set our options based on the command line
require 'optparse'

options = { :host => 'localhost', :port => 13666 }

OptionParser.new do |opt|
  opt.banner = "Usage: telnet [options]"
  opt.on('-h', "--host[#{options[:host]}]", 'Connect to a specific host.') { |v| options[:host] = v }
  opt.on('-p', "--port[#{options[:port]}]", 'Connect using a different port.') { |v| options[:port] = v }
  opt.parse!(ARGV)
end


def process_responses
	response = @daemon_socket.gets

	( puts " - #{response}"; @response_count += 1 ) unless response =~ /^ignore|listen/

	Thread.pass
end

# Start the main program by openning a telnet session and parsing stdin
require 'socket'

@response_count = 0

puts " Opening connection to LCDd..."

begin
	@daemon_socket = TCPSocket.new( options[:host], options[:port] )
	puts " Connection established, Ready to send commands\n\n"

	@listen = Thread.new { while true do process_responses end }

	puts " Listening for responses..."

	while true
		rc = @response_count

		print "lcdproc > "
		$stdout.flush

		input = $stdin.readline

		if input.strip == "exit"
			@daemon_socket.close
			puts " *waves goodbye*\n"

			break
		end

		@daemon_socket.write( input )

		while not @response_count > rc
			# Wait until we get a response
		end

	end

rescue Errno::ECONNREFUSED
	puts " Error: Connection to '#{options[:host]}':#{options[:port]} was refused."
end
