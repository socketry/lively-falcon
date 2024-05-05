
require 'lively'

require_relative 'game_of_life'
require_relative 'math_quest'
require_relative 'alphabet'

class Application < Lively::Application
	def self.resolver
		Live::Resolver.allow(GameOfLife, MathQuest, Alphabet)
	end
	
	def body
		# GameOfLife.new
		# MathQuest.new
		Alphabet.new
	end
end
