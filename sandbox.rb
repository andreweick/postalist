class Test
  def initialize(&block)
    @name = 'Rebecca'
    @proc = proc(&block)
  end
  
  def exec
    instance_eval(&@proc)
  end
end

test = Test.new {
  puts @name
}
test.exec