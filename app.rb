require 'sinatra'
require 'haml'
require 'base64'
require 'digest/sha2'
require 'encryptor'
require './helpers'

get '/' do
  haml :testform
end

get /.*/ do
  request.path
end

def authenticate
  if request.POST and request.POST['token'] then
    request.POST['token'] == token
  else
    false
  end
end

post /.*/ do
  redirect back if not authenticate
  haml :showpost
end