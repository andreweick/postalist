require 'spec_helper'
require 'templater'
require 'ostruct'

describe Templater do
  it "can wrap an object" do
    an_object = OpenStruct.new( one: 1, two: 2 )
    expect(Templater.new('{{one}}, {{two}}', an_object).render).to eq '1, 2'
  end

  it "can wrap a hash" do
    a_hash = { one: 1, two: 2 }
    expect(Templater.new('{{one}}, {{two}}', a_hash).render).to eq '1, 2'
  end

  it "can wrap multiple objects" do
    object1 = OpenStruct.new( one1: 1, one2: 2 )
    object2 = OpenStruct.new( one1: 'ignored', one2: 'ignored', two1: 21, two2: 22 )
    expect(Templater.new('{{one1}}, {{one2}}, {{two1}}, {{two2}}', object1, object2).render).to eq '1, 2, 21, 22'
  end

  it "can wrap multiple hashes" do
    hash1 = {one1: 1, one2: 2}
    hash2 = {one1: 'ignored', one2: 'ignored', two1: 21, two2: 22}
    expect(Templater.new('{{one1}}, {{one2}}, {{two1}}, {{two2}}', hash1, hash2).render).to eq '1, 2, 21, 22'
  end

  it "can wrap hash after object" do
    object1 = OpenStruct.new( one1: 1, one2: 2 )
    hash2 = {one1: 'ignored', one2: 'ignored', two1: 21, two2: 22}
    expect(Templater.new('{{one1}}, {{one2}}, {{two1}}, {{two2}}', object1, hash2).render).to eq '1, 2, 21, 22'
  end

  it "can wrap object after hash" do
    hash1 = {one1: 1, one2: 2}
    object2 = OpenStruct.new( one1: 'ignored', one2: 'ignored', two1: 21, two2: 22 )
    expect(Templater.new('{{one1}}, {{one2}}, {{two1}}, {{two2}}', hash1, object2).render).to eq '1, 2, 21, 22'
  end

  it "can wrap an object after a hash after an object" do
    object1 = OpenStruct.new( one1: 1, one2: 2 )
    hash2 = {one1: 'ignored', one2: 'ignored', two1: 21, two2: 22}
    object3 = OpenStruct.new( one1: 'ignored', two2: 'ignored', three1: 31, three2: 32 )

    template = '{{one1}}, {{one2}}, {{two1}}, {{two2}}, {{three1}}, {{three2}}'
    expect(Templater.new(template, object1, hash2, object3).render).to eq '1, 2, 21, 22, 31, 32'
  end
end
