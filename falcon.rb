#!/usr/bin/env -S falcon host
# frozen_string_literal: true

require_relative 'lib/application'

load Lively::Environments::Application

hostname = File.basename(__dir__)
port = ENV["PORT"] || 3000

host hostname, :lively do
	endpoint Async::HTTP::Endpoint.parse("http://0.0.0.0:#{port}").with(protocol: Async::HTTP::Protocol::HTTP11)
end
