before do
  @settings = Settings.new(request) if request.post?
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

get /^\/test.*/ do
  @settings = Settings.new(request, request.url)
  haml :testform
end

get /.*/ do
  request.path
end
