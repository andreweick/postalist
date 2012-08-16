require 'psych'

class Settings

  class << self
    def env
      ENV['RACK_ENV'] || :development
    end

    def settings_path
      File.expand_path("../../settings/#{env}", __FILE__)
    end

    def defaults
      @defaults ||= Psych.load(File.read(File.join(settings_path, 'defaults.yml')))
    end
  end

  def initialize(request, referer=false)
    @succeeded, @failed = false, false
    @request = request
    @flash = ''

    @referer = referer || @request.referer
    @settings_file = File.join(
      settings_path, 'referers',
      @referer.sub(%r{^http://(www\.)?},'').gsub(%r{:|\.},'_').sub(/_$/,''),
      'settings.yml'
    )
  end

  def settings_path
    self.class.settings_path
  end

  def settings
    @settings ||= self.class.defaults.deep_merge(
      Psych.load(File.read(@settings_file)) || {}
    )
  end

  def []=(*args)

  end

  def templater
    @templater ||= Templater.new(self)
  end

  def parse(string)
    return string unless string.is_a? String
    @templates ||= {}
    @templates[string] ||= Templater.new(self, string)
    @templates[string].render
  end

  def method_missing(symbol, *args, &block)
    if symbol[-1] == '='
      symbol = symbol[0..-2]
      case
        when block_given?
          settings[symbol.to_s] = proc(&block)
        when args.count == 1
          settings[symbol.to_s] = args[0]
        else
          settings[symbol.to_s] = args
      end
    elsif settings.has_key?(symbol.to_s) then
      if block_given? || args.count > 0 then
        self.send("#{symbol}=", *args, proc(&block))
      else
        parse(settings[symbol.to_s])
      end
    else
      super(symbol, *args, &block)
    end
  end

  def respond_to?(symbol)
    super || settings.has_key?(symbol) || settings.has_key?(symbol.to_s)
  end

  def succeeded?; @succeeded end
  def failed?; @failed end

  def flash
    URI.escape(@flash, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end

  def hex_pack string; Base64.encode64(string) end
  def hex_unpack string; Base64.decode64(string) end
  def post; @request.post? && @request.POST end

  def seed
    @seed ||= if post && post['token']
      hex_unpack(post['token'])[0..seed_length-1]
    else
      (0..seed_length-1).inject('') do |out, _|
        out << '0123456789abcdef'[rand(15)].chr
      end
    end
  end

  def token
    hex_pack(
      seed +
      Digest::SHA2.hexdigest(
        token_elements.inject('') do |out, el|
          out + send(el)
        end
      )
    )
  end

  def authenticate
    post && post['token'] && hex_unpack(post['token']) == hex_unpack(token)
  end

  def queue_mail
    mail_settings = mail_defaults.clone
    mail_settings[:to] = "jonathan@camenisch.net"
    mail_settings[:headers]['X-X-Sender'] = "Message posted on #{referer} from #{ip}"
    mail_settings[:subject] ||= mail_settings[:headers]['X-X-Sender']
    mail_settings[:via] = :sendmail

    Pony.mail(mail_settings)
  end

  def process
    begin
      queue_mail
      @succeeded = true
      catch do |e|
        @flash = 'Something went wrong'
        @failed = true
      end
    end
  end

  def next_action
    if succeeded? then
      success_action
    elsif failed? then
      failure_action
    else
      raise 'processing failed to complete'
    end
  end

  class Templater < Mustache
    def initialize(settings, _template)
      @settings = settings
      self.template = _template
    end

    def method_missing(symbol, *args, &block)
      @settings.send(symbol, *args, &block)
    end

    def respond_to?(symbol)
      super(symbol) ||  @settings.respond_to?(symbol)
    end
  end
end
