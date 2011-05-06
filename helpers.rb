class String
  def sha256
    Digest::SHA2.hexdigest(to_s)
  end
end

class Digest::Class
  def base36digest string
    hexdigest(string).to_i(16).to_s(36)
  end
end

helpers do
  def show string, label, processor=:sha256
    "#{label}: #{string} - #{processor}: #{string.send(processor)} (#{string.send(processor).length})"
  end
  def secret
    'something'
  end
  def hex_compress string
    string.to_i(16).to_s(36)
  end
  def hex_decompress string
    string.to_i(36).to_s(16)
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
      (
        (request.POST && request.POST['token'] ?
          request.referer :
          request.url
        ) +
        request.ip+seed+secret
      ).sha256
    )
  end
end