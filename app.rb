def actions
  {
    'email' =>  proc do
                  Email.new(@settings.mail, @request).send
                  :success
                end
  }
end

def authenticate
  @settings.authenticate
end

def do_actions(_actions, *args)
  if _actions.respond_to?(:each)
    _actions.each do |(action, options)|
      result = actions[action][*(options && options['args'])]
      if result == :success
        do_actions(options['on_success']) if options && options['on_success']
      else
        do_actions(options['on_failure'], result) if options && options['on_failure']
      end
    end
  elsif _actions.respond_to?(:=~) && _actions =~ %r(^https?://)
    redirect _actions
  end
end

before do
end

get /^\/test.*/ do
  @settings = Settings.new(request.url)
  @authenticator = Authenticator.new(request, @settings)
  haml :testform
end

get /.*/ do
  request.path
end

post /.*/ do
  @settings = Settings.new(request.referer)
  @authenticator = Authenticator.new(request, @settings)

  if @authenticator.authenticate? then
    do_actions(@settings.actions)
  else
    redirect back
  end
end
