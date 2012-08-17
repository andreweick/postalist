class Email
  def initialize(settings, request)
    @request = request

    # Convert keys to symbols for Pony's use
    # With settings in YAML, it's more user-friendly to initialize them as strings
    @settings = settings.symbolize_keys

    # Just for reading by things that want to render a Mustache template
    # from the settings object (e.g., the subject method)
    @settings[:referer] = request.referer
    @settings[:ip] = request.ip
  end

  attr_reader :settings, :request

  def form_hash
    request.env["rack.request.form_hash"]
  end

  def form_array
    form_hash.reduce([]) do |memo, (k,v)|
      memo << {key: k, value: v}
    end
  end

  def x_x_sender
    @x_x_sender ||= "Message posted on #{request.referer} from #{request.ip}"
  end

  def parsed(key)
    @parsed ||= {}
    @parsed[key] ||= settings[key] && Templater.parse(settings[key], settings, request.params, request)
  end

  def body
    'This is just some filler!'
  end

  def prepped_settings
    @prepped_settings ||= @settings.clone.tap do |s|
      # Convert most stuff to symbols for Pony's sake.
      s[:via] = s[:via].andand.to_sym || :sendmail
      s[:via_options] = s[:via_options].andand.symbolize_keys || {}

      s[:headers] ||= {}
      s[:headers]['X-X-Sender'] = x_x_sender
      s[:subject] = parsed(:subject) || x_x_sender
      s[:from] = parsed(:from)
      s[:body] = body
    end
  end

  def send
    Pony.mail(prepped_settings)
  end
end
