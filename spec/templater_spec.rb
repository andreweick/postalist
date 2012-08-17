require 'spec_helper'

$LOAD_PATH << File.expand_path('../lib',__FILE__)

require 'templater'
require 'ostruct'

describe Templater do
  it "can wrap an object" do
    an_object = OpenStruct.new( one: 1, two: 2 )
    expect(Templater.new(an_object, '{{one}}, {{two}}').render).to eq '1, 2'
  end

  it "can wrap a hash" do
    a_hash = { one: 1, two: 2 }
    expect(Templater.new(a_hash, '{{one}}, {{two}}').render).to eq '1, 2'
  end
end
