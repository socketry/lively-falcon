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

class MathQuest < Live::View
	class Equation
		def initialize(lhs, operator, rhs)
			@lhs = lhs
			@operator = operator
			@rhs = rhs
		end
		
		def answer
			@lhs.send(@operator, @rhs)
		end
		
		def to_s
			"#{@lhs} #{@operator} #{@rhs}"
		end
		
		def correct?(input)
			self.answer == input.to_i
		end
		
		def self.generate(level)
			case level
			when 0
				self.new(rand(0..10), "+", rand(0..10))
			when 1
				self.new(rand(0..20), "+", rand(0..20))
			when 2
				self.new(rand(0..10), ["+", "-"].sample, rand(0..10))
			when 3
				self.new(rand(-10..10), ["+", "-"].sample, rand(-10..10))
			when 4
				self.new(rand(0..10), "*", rand(0..10))
			else
				self.new(rand(-10..10), "*", rand(-10..10))
			end
		end
	end
	
	def initialize(...)
		super
		
		@data[:level] ||= 0
		@data[:time] ||= 60
		@data[:score] ||= 0
		
		@update = nil
		@equation = nil
	end
	
	def bind(page)
		super(page)
		
		self.reset
		self.start
	end
	
	def close
		self.stop
		super
	end
	
	def start
		@update ||= Async do |task|
			while true
				task.sleep(1.0)
				
				self.update!
			end
		end
	end
	
	def stop
		if @update
			@update.stop
			@update = nil
		end
	end
	
	def level
		(self.score/10).round
	end
	
	def score
		@data['score'].to_i
	end
	
	def score= score
		@data['score'] = score
	end
	
	def reset
		@answer = nil
		@equation = Equation.generate(self.level)
	end
	
	def handle(event)
		@answer = event.dig(:detail, :value)
		
		if @equation.correct?(@answer)
			self.reset
			self.score += 1
			
			self.update!
		end
	end
	
	def forward_value
		"live.forwardEvent(#{JSON.dump(@id)}, event, {action: 'change', value: event.target.value})"
	end
	
	def render(builder)
		builder.tag('p', class: 'toolbar') do
			builder.text "Score: #{self.score}"
		end
		
		builder.tag('p', class: 'equation') do
			if @equation
				builder.text @equation.to_s
				builder.text ' = '
				builder.inline('input', type: 'text', value: @answer, oninput: forward_value)
			else
				builder.text "Preparing..."
			end
		end
	end
end
