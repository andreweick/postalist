class Templater < Mustache
  def self.parse(*args)
    self.new(*args).render
  end

  def initialize(a_template, *args)
    @objects = args.map{|o| o.respond_to?(:has_key?) ? OpenStruct.new(o) : o }
    self.template = a_template
  end

  def send_to_wrapped(sym, *args, &block)
    @objects.reduce(nil) do |memo, obj|
      memo || (obj.respond_to?(sym) && obj.send(sym, *args, &block))
    end
  end

  def method_missing(sym, *args, &block)
    send_to_wrapped(sym, *args, &block) || (sym != :has_key? && super(sym, *args, &block))
  end

  def respond_to?(sym)
    super(sym) || send_to_wrapped(:respond_to?, sym) || send_to_wrapped(:has_key?, sym)
  end
end
