require 'rubygems'
require 'bundler/setup'
require 'simplecov'
require 'draw_cloud'

SimpleCov.start if ENV["COVERAGE"]

Dir['./spec/support/*.rb'].map {|f| require f }

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
