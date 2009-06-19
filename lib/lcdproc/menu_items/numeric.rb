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

	module MenuItems

		class Numeric
			include LCDProc::MenuItem
			LCDProc::MenuItem.add_support( :numeric, self )

			@@numeric_item_count = 0

			# Creates a new Numeric MenuItem object.
			#
			# The <tt>user_options</tt> will accept a hash of the following MenuItem options.
			#
			# * <tt>:id</tt> - The unique string that identifies this numeric. Defaults to "NumericMenuItem_" + a sequence number.
			#
			# The <tt>lcdproc_options</tt> will accept a hash of the options to be passed to LCDd when creating or updating the numeric.
			#
      # * <tt>:text</tt> - The text to be displayed on the LCD for this numeric. Defaults to the id.
      # * <tt>:minvalue</tt> - The minimum value that the numeric should allow. Defaults to 0 but can be negative.
			# * <tt>:maxvalue</tt> - The maximum value that the numeric should allow. Defaults to 100.
			def initialize( user_options = {}, lcdproc_options = {} )
				@lcdproc_options = {}

				if user_options[:id].nil?
					@id = "NumericMenuItem_#{@@numeric_item_count}"
				else
					@id = user_options[:id]
				end

				@lcdproc_type = "numeric"
				@lcdproc_event_type = "update"
				
				@lcdproc_options[:text] = @id

				@lcdproc_options[:minvalue] = 0
				@lcdproc_options[:maxvalue] = 100

				@lcdproc_options.update( lcdproc_options )

				@lcdproc_options[:text] = "\"#{@lcdproc_options[:text]}\""

				@@numeric_item_count += 1
			end
		end

	end

end
