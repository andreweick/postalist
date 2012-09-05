class Email
  def initialize(settings, request)
    @request = request
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
    @x_x_sender ||= parse('Message posted on {{referer}} from {{ip}}')
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

  def mail
    @mail ||= Mail.new.tap do |m|
      m.from    = parsed(:from)
      m.to      = settings[:to]
      m.subject = (parsed(:subject) || x_x_sender)
      (settings[:headers] || {}).each do |key, value|
        m[key] = value
      end
      m['X-X-Sender'] = x_x_sender
      m.body = body
    end
  end

  def send
    mail.deliver!
  end
end
