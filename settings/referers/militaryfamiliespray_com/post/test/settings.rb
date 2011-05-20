module MilitaryfamiliesprayCom
  module Post
    module Test

      class Settings < SettingsBase
        
        seed_length 11
        on_success 'http://www.militaryfamiliespray.com/Post/thank-you'
        on_failure do
          "#{@request.referer}?message=#{flash}"
        end
        
        def authenticate
          true
        end

      end

    end
  end
end