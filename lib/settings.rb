require './lib/settings_base'

class SettingsFactory

  def self.get_for(req, referer=false)
    referer ||= req.referer
    class_file = referer.sub(%r{^http://(www\.)?},'').gsub(%r{:|\.},'_').sub(/_$/,'')
    if File.exists?("./settings/referers/#{class_file}/settings.rb") then
      require "./settings/referers/#{class_file}/settings"
      klass = eval "#{class_file.camelize}::Settings"
      klass.new(req)
    else
      raise class_file #DefaultSettings.new(req)
    end
  end

end

class DefaultSettings < SettingsBase
  def authenticate
    false
  end
end