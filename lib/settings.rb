class Settings

  @@settings_skel = {
    on_success: 'http://camenischcreative.com/',
    on_failure: 'http://cnn.com',
    token_elements: [:referer, :ip, :seed, :secret],
    seed_length: 5,
    success_action: Proc.new { [:redirect, on_success] },
    failure_action: Proc.new { [:redirect, on_failure] },
    referer: Proc.new { @request.referer },
    url: Proc.new { @request.url },
    ip: Proc.new { @request.ip },
    secret: 'something',
    mail_defaults: {
      from: 'webform@camenischcreative.com',
      via: :smtp,
      via_options: {
        host: 'smtp.gmail.com'
      },
      to: :em_to,
      cc: :em_cc,
      bcc: :em_bcc,
      from: :em_from,
      subject: :em_subject,
      #charset: ,
      headers: {},
      #message_id: ,
      sender: 'webform@camenischcreative.com'
    }
  }

  def initialize(request, referer=false)
    @succeeded, @failed = false, false
    @request = request
    @flash = ''

    referer ||= request.referer
    settings_file = referer.sub(%r{^http://(www\.)?},'')
                           .gsub(%r{:|\.},'_')
                           .sub(/_$/,'')
    settings_file = "./settings/referers/#{settings_file}/settings.rb"
    if File.exists?(settings_file) then
      instance_eval(File.open(settings_file, 'rb').read)
    else
      raise "Cannot find #{settings_file}"
    end
  end

  def self.settings
    @settings ||= @@settings_skel.clone
  end
  def settings; self.class.settings end

  def self.method_missing(symbol, *args, &block)
    if settings.has_key?(symbol) then
      case args.count
        when 0
          if block_given? then
            settings[symbol] = block
          else
            settings[symbol]
          end
        when 1
          settings[symbol] = args[0]
        when 2
          settings[symbol] = args
      end
    else
      super
    end
  end

  def method_missing(symbol, *args)
    if settings.has_key?(symbol) then
      if settings[symbol].is_a?(Proc)
        instance_eval(&settings[symbol])
      else
        settings[symbol]
      end
    else
      raise
    end
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

end
