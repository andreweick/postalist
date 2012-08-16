require 'spec_helper'

$LOAD_PATH << File.expand_path('../lib',__FILE__)

require 'settings'
require 'ostruct'

describe Settings do
  before(:all) do
    @request = OpenStruct.new(
      referer: 'http://test.com/'
    )
    @settings_root = File.expand_path('../../settings/test', __FILE__)
    @defaults_filename = File.join(@settings_root, 'defaults.yml')
    @settings_filename = File.join(@settings_root, 'referers/test_com/settings.yml')

    File.open(@defaults_filename, 'w') do |f|
      f.write <<-eof
one: 1
two: 2
      eof
    end
    `touch #{@settings_filename}`
  end

  after(:all) do
    `rm #{@defaults_filename}`
    `rm #{@settings_filename}`
  end

  before(:each) do
    @settings = Settings.new(@request)
  end

  context "with all default settings" do
    before(:all) do
      File.open(@settings_filename, 'w') {|f| f.write '' }
    end

    it "reads settings from defaults" do
      expect(@settings.one).to eq 1
    end
  end

  context "with custom settings" do
    before(:all) do
      File.open(@settings_filename, 'w') do |f|
        f.write <<-eof
one: 'custom 1'
three: 3
late_bound: '{{one}} {{three}}'
        eof
      end
    end

    it "read custom settings based on referer" do
      expect(@settings.one).to eq 'custom 1'
      expect(@settings.three).to eq 3
    end

    it "compiles late-bound properties via handlebars syntax" do
      expect(@settings.late_bound).to eq 'custom 1 3'
    end
  end
end
