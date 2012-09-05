ENV['RACK_ENV'] = 'test'
$LOAD_PATH << File.expand_path('../lib',__FILE__)

require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'])

require 'rspec/mocks'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
