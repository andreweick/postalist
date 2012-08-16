require 'rubygems'
require 'bundler'

Bundler.require

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
