class Email
  def initialize(settings, request)
    @request = request

    # Convert keys to symbols for Pony's use
    # With settings in YAML, it's more user-friendly to initialize them as strings
    @settings = settings.symbolize_keys
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
    @x_x_sender ||= ""
  end

  def parse(template)
    Templater.parse(template, settings, request.params, request)
  end

  def parsed(key)
    (@parsed ||= {})[key] ||= parse(settings[key])
  end

  def body
    return @body if @body
    if settings[:template]
      @body = parse(File.read(settings[:template]))

      extensions = settings[:template][/\.[^\/]+$/].split('.')
      extensions.delete('mustache')
      extensions.delete('')

      extensions.each do |format|
        @body = Tilt[format].new{@body}.render
      end
    end
    @body
  end

  def prepped_settings
    @prepped_settings ||= @settings.clone.tap do |s|
      # Convert most stuff to symbols for Pony's sake.
      s[:via] = s[:via].andand.to_sym || :sendmail
      s[:via_options] = s[:via_options].andand.symbolize_keys || {}

      s[:headers] ||= {}
      s[:headers]['X-X-Sender'] = parse('Message posted on {{referer}} from {{ip}}')
      s[:subject] = parsed(:subject) || x_x_sender
      s[:from] = parsed(:from)
      s[:body] = body
    end
  end

  def send
    Pony.mail(prepped_settings)
  end
end
