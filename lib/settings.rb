require './lib/settings_base'

class SettingsFactory
  def self.get_for(req, referer=false)
    referer ||= req.referer
    class_file = referer.sub(%r{^http://},'').gsub(%r{/|:},'_').sub(/_$/,'')
    if File.exists?("./settings/referers/#{class_file}.rb") then
      require "./settings/referers/#{class_file}"
      klass = eval "#{class_file.camelize}Settings"
      klass.new(req)
    else
      DefaultSettings.new(req)
    end
  end
end

class DefaultSettings < SettingsBase
  def authenticate
    false
  end
end