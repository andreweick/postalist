require 'active_support/inflector'
require 'sinatra'
require 'haml'
require 'base64'
require 'digest/sha2'
require 'encryptor'
require 'uri'
require './lib/helpers'
require './lib/settings'
require './app'

run Sinatra::Application
