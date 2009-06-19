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

# Example: clock.rb
# Author:  Topher Fangio
# Date:    9.17.2008
#
# Purpose: This program displays a simple clock on the LCD that updates every 5 seconds.
#          This will most likely be extracted into it's own Widget at a later date, but
#          it makes a very good beginners example for now.

require "lcdproc"

include LCDProc

c = Client.new( :host => "localhost" )
s = Screen.new("clock")

hour1 = Widgets::Num.new("hour1", 0, 3)
hour2 = Widgets::Num.new("hour2", 1, 7)
colon = Widgets::Num.new("colon", 10, 10)
minute1 = Widgets::Num.new("minute1", 0, 12)
minute2 = Widgets::Num.new("minute2", 0, 16)

s.add_widget(hour1)
s.add_widget(hour2)
s.add_widget(colon)
s.add_widget(minute1)
s.add_widget(minute2)

c.attach( s )

while true do
  t = Time.new
  
  if (t.hour > 10)
    hour1.number = t.hour / 10
    hour2.number = t.hour % 10
  else
    hour1.number = 0
    hour2.number = t.hour
  end
  
  if (t.min > 10)
    minute1.number = t.min / 10
    minute2.number = t.min % 10
  else
    minute1.number = 0
    minute2.number = t.min
  end
  
  s.update
  sleep 5
end
