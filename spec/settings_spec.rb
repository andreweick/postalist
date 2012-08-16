require 'spec_helper'

$LOAD_PATH << File.expand_path('../lib',__FILE__)

require 'settings'
require 'ostruct'

describe Settings do
  before(:all) do
    @request = OpenStruct.new(
      referer: 'http://test.com/'
    )
    @dir = File.expand_path('../../settings/referers/test_com', __FILE__)

    `mkdir #{@dir} && touch #{File.join(@dir, 'settings.yml')}`
  end

  after(:all) do
    `rm -r #{@dir}`
  end

  before(:each) do
    @settings = Settings.new(@request)
  end

  context "with all default settings" do
    before(:all) do
      File.open(File.join(@dir, 'settings.yml'), 'w') do |f|
        f.write ''
      end
    end

    it "supplies settings hash to instances" do
      expect(@settings.on_failure).to eq 'http://cnn.com'
    end
  end
end
