module Localhost9292
  module Test

    class Settings < SettingsBase
      seed_length 5
      success_action :haml, :showpost
      referer do
        @request.get? ? @request.url : @request.referer
      end
      ip '72.198.74.62'
    end

  end
end