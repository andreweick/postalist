class SettingsBase
  
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
    secret: 'something'
  }

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
      settings[symbol].is_a?(Proc) ?
        instance_eval(&settings[symbol]) :
        settings[symbol]
    else
      raise
    end
  end
  
  def initialize(request)
    @succeeded, @failed = false, false
    @request = request
  end

  def succeeded?; @succeeded end
  def failed?; @failed end
  
  def hex_pack string
    Base64.encode64(string)
  end
  def hex_unpack string
    Base64.decode64(string)
  end

  def post; @request.post? && @request.POST end
  
  def seed
    @seed ||= post && post['token'] ?
      hex_unpack(post['token'])[0..settings[:seed_length]-1] :
      (0..settings[:seed_length]-1).inject('') { |out,i|
        out + '0123456789abcdef'[rand(15)].chr
      }
  end
  
  def token
    hex_pack(
      seed +
      Digest::SHA2.hexdigest(
        token_elements.inject('') do |out,el|
          out + send(el)
        end
      )
    )
  end
  
  def authenticate
    if post and post['token'] then
      hex_unpack(post['token']) == hex_unpack(token)
    else
      false
    end
  end
  
  def process
    @succeeded = true
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