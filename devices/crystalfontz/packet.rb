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
  module Devices
    module Crystalfontz
      
      module Packet
        VALID_KEYS = [ "Escape", "Enter", "Up", "Down", "Left", "Right" ]
        
        @drives_devices = [ "CrystalFontz Driver: CFA-635" ]
        
        LCDProc::Devices.send( :include, self )
        
        
        def Packet.drives?( search )
          @drives_devices.include? search
        end
        
        
        # Called before initialization takes place.
        def before_initialize( options = {} )
          # Do nothing
        end
        
        
        # Called after initialization takes place.
        def after_initialize( options = {} )
          @leds = { 0 => 0, 1 => 0, 2 => 0, 3 => 0 }
        end
        
        
        # Make the specified leds light up.
        #
        # * <tt>leds</tt> - The leds that you wish to light. They may be specified as a single number, a range (1..3), an array [0,2] or the special parameter :all.
        # * <tt>color</tt> - The color that you wish to light the leds. Valid options are :off, :green, :orange, or :red.
        def light_leds( leds, color )
          
          if leds == :all
            leds_to_light = @leds.keys
          elsif leds.kind_of? Range
            leds_to_light = leds.to_a
          else
            leds_to_light = ( leds.kind_of?( Array ) ? leds : [ leds ] )
          end
          
          if leds_to_light.max > @leds.keys.max
            add_message( "Error: Led '#{leds_to_light.max}' does not correspond to an actual led." )
            return false
          end
          
          case color
            when :off
            leds_to_light.each{ |l| @leds[l] = 0 }
            when :green
            leds_to_light.each{ |l| @leds[l] = 2 ** l }
            when :orange
            leds_to_light.each{ |l| @leds[l] = 2 ** l * 16 + 2 ** l }
            when :red
            leds_to_light.each{ |l| @leds[l] = 2 ** l * 16 }
          else
            add_message( "Error: Unknown color '#{color}'" )
            return false
          end
          
          command = Command.new( "output #{ @leds.values.sum }" )
          response = send_command( command )
          
          if response.successful?
            add_message( "Leds #{leds_to_light} were correctly lit" )
            return true
          else
            add_message( "Leds #{leds_to_light} were NOT correctly lit (#{response.message})" )
            return false
          end
          
        end
        
      end
      
    end
    
  end
  
end
