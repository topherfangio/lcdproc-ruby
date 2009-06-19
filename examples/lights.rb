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

# Example: lights.rb
# Author:  Topher Fangio
# Date:    9.17.2008
#
# Purpose: This program iterates through the available lights and turns them red.
#          Note that at the moment, only one device has been defined that supports
#          leds, the CrystalFontz display defined in devices/crystalfontz/packet.rb.

require "lcdproc"
include LCDProc

# Setup our client
c = Client.new( :host => "192.168.1.142" )

@current_led = 0
@color = :red

# Define a method to modify the current led
def move_current_led(direction)
  @current_led += direction
  
  if (@current_led > 3)
    @current_led = 0
  end
  
  if (@current_led < 0)
    @current_led = 3
  end
  
  return @current_led
end

while true
  c.light_leds(:all, :off)
  c.light_leds(@current_led, :red)

  move_current_led(1)

  sleep 1
end
