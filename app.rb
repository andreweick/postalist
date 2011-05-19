require 'sinatra'
require 'haml'
require 'base64'
require 'digest/sha2'
require 'encryptor'
require './lib/helpers'
require './lib/settings'

before do
  @settings = SettingsFactory.get_for(request) if request.post?
end

def authenticate
  @settings.authenticate
end

post %r{^/test.*} do
  if authenticate then
    haml :showpost
  else
    redirect back
  end
end

get %r{^/test.*} do
  @settings = SettingsFactory.get_for(request, request.url)
  haml :testform
end

get /.*/ do
  request.path
end

