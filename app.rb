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
    hex_decompress(request.POST['token']) == hex_decompress(token)
  else
    false
  end
end

post '/test' do
  if authenticate then
    haml :showpost
  else
    redirect back
  end
end