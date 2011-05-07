helpers do
  def show string, label, processor=:sha256
    "#{label}: #{string} - #{processor}: #{string.send(processor)} (#{string.send(processor).length})"
  end
  def secret
    'something'
  end
  def hex_compress string
    #string.to_i(16).to_s(36)
    Base64.encode64(string)
  end
  def hex_decompress string
    #string.to_i(36).to_s(16)
    Base64.decode64(string)
  end
  def seed
    @seed ||= (
      request.POST && request.POST['token'] ?
        hex_decompress(request.POST['token']) :
        rand(999999).to_s(36).sha256
    ).chomp[0..10]
  end
  def token
    hex_compress(
      seed +
      Digest::SHA2.hexdigest(
        (request.POST && request.POST['token'] ?
          request.referer :
          request.url
        ) +
        request.ip +
        seed +
        secret
      )
    )
  end
end