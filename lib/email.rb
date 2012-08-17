class Email
  def initialize(settings, request)
    @request = request

    # Convert keys (and some values) to symbols for Pony's use
    # With settings in YAML, it's more user-friendly to initialize them as strings
    @settings = settings.symbolize_keys
    @settings[:via_options] = @settings[:via_options].andand.symbolize_keys
    @settings[:via] = @settings[:via].to_sym
    @settings[:referer] = request.referer
    @settings[:ip] = request.ip
  end

  attr_reader :settings, :request

  def send
    settings[:headers] ||= {}
    settings[:headers]['X-X-Sender'] = "Message posted on #{request.referer} from #{request.ip}"
    settings[:subject] = settings[:subject] ? Templater.parse(settings, settings[:subject]) : settings[:headers]['X-X-Sender']

    Pony.mail(settings)
  end

end
