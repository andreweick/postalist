LOG = File.new("app.log", "a+")
$stdout.reopen(LOG)
$stderr.reopen(LOG)

require 'rubygems'
require 'bundler'

Bundler.require

$LOAD_PATH << File.expand_path('../lib',__FILE__)

require 'base64'
require 'digest/sha2'
require 'uri'

require 'sinatra'

require 'helpers'
require 'templater'
require 'email'
require 'settings'
require './app'

run Sinatra::Application
