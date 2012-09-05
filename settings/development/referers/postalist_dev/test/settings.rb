seed_length = 5
success_action = :haml, :showpost
on_success = 'http://google.com/'
def referer
  @request.get? ? @request.url : @request.referer
end
ip = '72.198.74.62'
