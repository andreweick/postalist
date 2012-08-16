ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'

Bundler.require

require 'templater'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
