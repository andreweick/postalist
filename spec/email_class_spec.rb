require 'spec_helper'
require 'templater'
require 'email'
require 'ostruct'

describe Email do
  before(:all) do
    @some_settings = {
      'to' => 'test@camenisch.net',
      'subject' => 'New message from {{referer}}',
      'from' => '"{{name}}" <{{email}}>'
    }
    @request = OpenStruct.new(
      referer: 'http://anypost.dev/test',
      params: {
        name: 'Jed Clampett',
        email: 'jed@clampett.io'
      }
    )
  end

  before(:each) do
    # Hijack deliver method to not send email
    Pony.stub(:deliver)
  end

  it "should be set to be delivered to the configured email address" do
    email = Email.new(@some_settings, @request)
    Pony.should_receive(:mail) do |params|
      expect(params[:from]).to eq '"Jed Clampett" <jed@clampett.io>'
      expect(params[:to]).to eq "test@camenisch.net"
      expect(params[:subject]).to include("New message from http://anypost.dev/test")

      #expect(params[:body]).to include("You've been invited to blah")
      #expect(params[:body]).to include("/#{@account_id}/new-user/register")
    end
    email.send
  end

  it "should render its body from a template file, processing via Mustache and Tilt" do
    settings = @some_settings.clone.tap do |s|
      s[:template] = 'email.md.mustache'
    end
    File.open(settings[:template], 'w') do |template|
      template.write <<-eof
New message posted at {{referer}}
=================================

to: {{to}}

From: {{name}} at {{email}}
      eof
    end

    email = Email.new(settings, @request)

    Pony.should_receive(:mail) do |params|
      expect(params[:body].to_s).to eq <<-eos
<h1 id='new_message_posted_at_httpanypostdevtest'>New message posted at http://anypost.dev/test</h1>

<p>to: test@camenisch.net</p>

<p>From: Jed Clampett at jed@clampett.io</p>
      eos
      .chomp
    end
    email.send
  end
end
