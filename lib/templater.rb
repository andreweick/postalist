class Templater < Mustache
  def initialize(data, _template)
    @data = data
    self.template = _template
  end

  def method_missing(symbol, *args, &block)
    @data.send(symbol, *args, &block)
  end

  def respond_to?(symbol)
    super(symbol) ||  @data.respond_to?(symbol)
  end
end
