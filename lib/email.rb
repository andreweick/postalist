class Email
  def initialize(settings, request)
    @settings = settings.symbolize_keys
    @settings[:via] = @settings[:via].to_sym
    @request = request
  end

  attr_reader :settings

  def send
    settings[:headers] ||= {}
    settings[:headers]['X-X-Sender'] = "Message posted on #{@request.referer} from #{@request.ip}"
    settings[:subject] ||= settings[:headers]['X-X-Sender']

    Pony.mail(settings)
  end

end
