# frozen_string_literal: true

# Copyright, 2021, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'live/view'

class Alphabet < Live::View
	LETTERS = ('A'..'Z').to_a
	
	class Color < Struct.new(:h, :s, :l)
		def to_s
			"hsl(#{h}, #{s}%, #{l}%)"
		end
		
		def self.mix(*colors)
			result = Color.new(rand(60.0), 0.0, 0.0)
			
			colors.each do |color|
				result.h += color.h
				result.s += color.s
				result.l += color.l
			end
			
			result.h = (result.h / colors.size).round
			result.s = (result.s / colors.size).round
			result.l = (result.l / colors.size).round
			
			return result
		end
		
		def self.generate
			self.new(rand(360.0), 80, 80)
		end
	end
	
	def initialize(id, **data)
		data[:index] ||= 0
		
		super
	end
	
	def index
		@data[:index].to_i
	end
	
	def index= value
		@data[:index] = value
	end
	
	def handle(event)
		self.index += 1
		self.replace!
	end
	
	def render(builder)
		builder.tag('p', class: 'toolbar') do
			builder.inline('button', onclick: forward(action: 'next')) do
				builder.text("Next")
			end
		end
		
		style = "color: #{Color.generate}"
		
		builder.tag('p', class: 'equation', style: style) do
			builder.text LETTERS[self.index % LETTERS.size]
		end
	end
end
