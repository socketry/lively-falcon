
require 'lively'

require_relative 'game_of_life'
require_relative 'math_quest'
require_relative 'alphabet'

class Switcher < Live::View
	View = Struct.new(:name, :tag)
	
	class << self
		attr :views, true
		
		def inherited(klass)
			klass.views = []
		end
		
		def add_view(name, tag)
			@views << View.new(name, tag)
		end
	end
	
	def self.build
		klass = Class.new(self)
		
		yield klass
		
		return klass
	end
		
	def initialize(...)
		super
		
		@current = nil
	end
	
	def switch(index)
		@data[:index] = index
		
		@current&.close
		@current = self.class.views[index].tag.new
		
		self.update!(bind: true)
	end
	
	def handle(event)
		detail = event[:detail]
		
		case detail[:action]
		when 'switch'
			self.switch(detail[:index])
		end
	end
	
	def render(builder)
		builder.tag('p', class: 'toolbar') do
			self.class.views.each_with_index do |view, index|
				builder.inline('button', onclick: forward_event(action: 'switch', index: index)) do
					builder.text(view.name)
				end
			end
		end
		
		if @current
			builder << @current.to_html
		end
	end
end

MySwitcher = Switcher.build do |switcher|
	switcher.add_view('Game of Life', GameOfLife)
	switcher.add_view('Math Quest', MathQuest)
	switcher.add_view('Alphabet', Alphabet)
end

class Application < Lively::Application
	def self.resolver
		Live::Resolver.allow(MySwitcher, GameOfLife, MathQuest, Alphabet)
	end
	
	def body
		MySwitcher.new
	end
end
