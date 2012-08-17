class Templater < Mustache
  def self.parse(data, _template)
    self.new(data, _template).render
  end

  def initialize(data, _template)
    @data = data
    self.template = _template

    if @data.respond_to?(:has_key?)
      instance_eval do
        def has_key?(key)
          @data.has_key?(key)
        end
      end
    end
  end

  def method_missing(symbol, *args, &block)
    @data.send(symbol, *args, &block)
  end

  def respond_to?(symbol)
    super(symbol) ||  @data.respond_to?(symbol)
  end

  def [](key)
    @data[key]
  end
end
