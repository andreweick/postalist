ENV['RACK_ENV'] = 'test'
$LOAD_PATH << File.expand_path('../lib',__FILE__)

require 'rubygems'
require 'bundler'
Bundler.require

require 'rspec/mocks'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include ::EmailSpec::Helpers
  config.include ::EmailSpec::Matchers
end
