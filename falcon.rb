#!/usr/bin/env -S falcon host
# frozen_string_literal: true

require_relative 'lib/application'

hostname = File.basename(__dir__)

service "lively-falcon" do
	include Lively::Environment::Application
	
	port do
		ENV["PORT"] || 3000
	end
	
	endpoint do
		Async::HTTP::Endpoint.parse("http://localhost:#{port}").with(protocol: Async::HTTP::Protocol::HTTP11)
	end
end
