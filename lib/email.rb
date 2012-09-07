class Email
  def initialize(settings, request)
    @request = request
    @settings = settings.symbolize_keys
  end

  attr_reader :settings, :request

  def form_hash
    request.env["rack.request.form_hash"]
  end

  def form_array
    form_hash.reduce([]) do |memo, (k,v)|
      memo << {key: k, value: v}
    end
  end

  def x_x_sender
    @x_x_sender ||= parse('Message posted on {{referer}} from {{ip}}')
  end

  def form_fields
    request.env.andand["rack.request.form_hash"]
  end

  def user_form_fields
    @user_form_fields ||= form_fields.andand.reject{|k, _| k == 'token' }
  end

  def user_form_fields_array
    user_form_fields.andand.reduce([]) do |memo, (k, v)|
      memo << {name: k, value: v}
    end
  end

  def parse(template)
    Templater.parse(template, settings, request.params, request, {form_fields: user_form_fields_array})
  end

  def parsed(key)
    (@parsed ||= {})[key] ||= parse(settings[key])
  end

  def template_extensions
    @template_extensions ||= settings[:template][/\.[^\/]+$/].split('.').delete_if{|e| e == '' }
  end

  def template_text
    @template_text ||= settings[:template] && parse(File.read(settings[:template]))
  end

  def html_body
    return @html_body if @html_body
    if template_text
      @html_body = template_text

      template_extensions.reject{|e| e == 'mustache' }.each do |format|
        @html_body = Tilt[format].new{@html_body}.render
      end
    end
    @html_body
  end

  def plaintext_body
    return @plaintext_body if @plaintext_body
    if template_text
      @plaintext_body = template_text

      template_extensions.reject{|e| e =~ /^(mustache|markdown|mkd|md|textile)$/ }.each do |format|
        @plaintext_body = Tilt[format].new{@plaintext_body}.render
      end
    end
    @plaintext_body
  end

  def mail
    @mail ||= Mail.new.tap do |m|
      m.from    = parsed(:from)
      m.to      = settings[:to]
      m.subject = (parsed(:subject) || x_x_sender)
      (settings[:headers] || {}).each do |key, value|
        m[key] = value
      end
      m['X-X-Sender'] = x_x_sender

      m.html_part = Mail::Part.new do
        content_type 'text/html; charset=UTF-8'
      end
      m.html_part.body = html_body

      m.text_part = Mail::Part.new
      m.text_part.body = self.plaintext_body
    end
  end

  def send
    mail.deliver!
  end
end
