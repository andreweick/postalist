class SettingsBase
  attr_reader :referer_config

  def initialize(req)
    @request = req
  end
  
  def secret
    'something'
  end
  
  def hex_pack string
    #string.to_i(16).to_s(36)
    Base64.encode64(string)
  end
  
  def hex_unpack string
    #string.to_i(36).to_s(16)
    Base64.decode64(string)
  end
  
  def post
    @request.post? && @request.POST
  end
  def referer
    @request.referer
  end
  def url
    @request.url
  end
  def ip
    @request.ip == '127.0.0.1' ?
      '72.198.74.62' :
      @request.ip
  end
  
  def seed(size=5)
    @seed ||= (
      post && post['token'] ?
        hex_unpack(post['token']) :
        (0..size-1).inject(''){|out,i|
          out+'0123456789abcdef'[rand(15)].chr
        }
    ).chomp[0..size-1]
  end
  
  def token
    hex_pack(
      seed +
      Digest::SHA2.hexdigest(
        referer + ip + seed + secret
      )
    )
  end
  def test_token
    hex_pack(
      seed +
      Digest::SHA2.hexdigest(
        url + ip + seed + secret
      )
    )
  end
  
  def authenticate
    if post and post['token'] then
      hex_unpack(post['token']) == hex_unpack(token)
    else
      false
    end
  end
  
end