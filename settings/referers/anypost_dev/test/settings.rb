seed_length 5
success_action :haml, :showpost
referer do
  @request.get? ? @request.url : @request.referer
end
ip '72.198.74.62'
