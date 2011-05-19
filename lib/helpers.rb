helpers do
  def show string, label, processor=:sha256
    "#{label}: #{string} - #{processor}: #{string.send(processor)} (#{string.send(processor).length})"
  end
end