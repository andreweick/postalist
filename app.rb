before do
  @settings = SettingsFactory.get_for(request) if request.post?
end

def authenticate
  @settings.authenticate
end

post /.*/ do
  if authenticate then
    @settings.process
    send(*@settings.next_action)
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