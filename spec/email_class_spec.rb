require 'spec_helper'
require 'templater'
require 'email'
require 'ostruct'

Mail.defaults do
  delivery_method :test
end

describe Email do
  before(:all) do
    @some_settings = {
      'to' => 'test@camenisch.net',
      'subject' => 'New message from {{referer}}',
      'from' => '"{{name}}" <{{email}}>'
    }
    @request = OpenStruct.new(
      referer: 'http://anypost.dev/test',
      ip: '127.0.0.1',
      params: {
        name: 'Jed Clampett',
        email: 'jed@clampett.io'
      }
    )
  end

  it "should be set to be delivered to the configured email address" do
    email = Email.new(@some_settings, @request).mail
    expect(email[:from].to_s).to eq 'Jed Clampett <jed@clampett.io>'
    expect(email[:to].to_s).to eq "test@camenisch.net"
    expect(email[:subject].to_s).to eq "New message from http://anypost.dev/test"

    #expect(params[:body]).to include("You've been invited to blah")
    #expect(params[:body]).to include("/#{@account_id}/new-user/register")
  end

  it "should render its body from a template file, processing via Mustache and Tilt" do
    settings = @some_settings.clone.tap do |s|
      s[:template] = 'email.md.mustache'
    end
    File.open(settings[:template], 'w') do |template|
      template.write %(
New message posted at {{referer}}
=================================

to: {{to}}

From: {{name}} at {{email}}
      )
    end

    begin
      email = Email.new(settings, @request).mail

      expect(email.body).to eq %(
<h1 id='new_message_posted_at_httpanypostdevtest'>New message posted at http://anypost.dev/test</h1>

<p>to: test@camenisch.net</p>

<p>From: Jed Clampett at jed@clampett.io</p>
      ).strip
    ensure
      File.delete(settings[:template])
    end
  end
end
