require 'psych'
require 'templater'

class Settings

  class << self
    def env
      ENV['RACK_ENV'] || :development
    end

    def settings_root
      File.expand_path("../../settings#{'/test' if env == 'test'}", __FILE__)
    end

    def defaults
      @defaults ||= Psych.load(File.read(File.join(settings_root, 'defaults', 'settings.yml')))
    end
  end

  def initialize(referer)
    @succeeded, @failed = false, false
    @referer = referer
  end

  attr_reader :referer
  attr_writer :flash

  def settings_root
    self.class.settings_root
  end

  def settings_path
    @settings_path = File.join(
      settings_root,
      referer.sub(%r{^https?://(www\.)?},'').gsub(/:|\./,'_').sub(/_$/,'')
    )
  end

  def settings_file
    File.join(settings_path, 'settings.yml')
  end

  def settings
    @settings ||= self.class.defaults.deep_merge(
      Psych.load(File.read(settings_file)) || {}
    )
  end

  def mail
    settings['mail'].tap do |h|
      h[:template] = Dir.glob(File.join(settings_path, 'email.*')).first
    end
  end

  def parse(string)
    return string unless string.is_a? String
    @templates ||= {}
    @templates[string] ||= Templater.new(string, self)
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

  def flash=(value)
    @flash = value
  end

  def flash
    @flash && URI.escape(@flash, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end

  def actions
    settings['actions'] || {
      settings['action'] => {
        'on_success' => settings['on_success'],
        'on_failure' => settings['on_failure']
      }
    }
  end

  def process
    begin
      queue_mail
      @succeeded = true
      catch do |e|
        self.flash = 'Something went wrong'
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
