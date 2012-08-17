class Templater < Mustache
  def self.parse(*args)
    self.new(*args).render
  end

  def initialize(a_template, *args)
    @objects = args
    self.template = a_template
  end

  def send_to_wrapped(sym, *args, &block)
    @objects.reduce(nil) do |memo, obj|
      case
        when memo
          memo
        when obj.respond_to?(sym)
          obj.send(sym, *args, &block)
        when !block_given? && args.empty? && obj.respond_to?(:[])
          obj[sym]
        else
          memo
      end
    end
  end

  def method_missing(sym, *args, &block)
    send_to_wrapped(sym, *args, &block)
  end

  def respond_to?(sym)
    super(sym) || send_to_wrapped(:respond_to?, sym) || send_to_wrapped(:has_key?, sym)
  end

  def [](key)
    send_to_wrapped key
  end
end
