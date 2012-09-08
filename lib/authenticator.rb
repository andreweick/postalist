class Authenticator

  class << self
    def pack(string)
      Base64.encode64(string)
    end

    def unpack(string)
      Base64.decode64(string)
    end

    def seed(length, token = nil)
      @seed ||= if token
        unpack(token)[0..length-1]
      else
        (0..length-1).inject(''){|memo, _| memo << rand(15).to_s(16) }
      end
    end
  end

  def initialize(request, settings)
    @request, @settings = request, settings
  end

  def pack(string); self.class.pack(string); end

  def unpack(string); self.class.unpack(string); end

  def seed
    self.class.seed(@settings.seed_length, post.andand['token'])
  end

  def timestamp
    post.andand['timestamp'].andand.to_f || Time.new.to_f
  end

  def token
    pack(
      seed +
      Digest::SHA2.hexdigest(
        @settings.token_elements.inject('') do |out, el|
          out << case
          when respond_to?(el)
            send(el)
          when @request.respond_to?(el)
            @request.send(el)
          else
            @settings.send(el)
          end.to_s
        end
      )
    ).gsub(/\s/,'')
  end

  def post
    @request.post? && @request.POST
  end

  def authenticate?
    post.andand['token'] && unpack(post['token']) == unpack(token)
  end

end
