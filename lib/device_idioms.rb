module DeviceIdioms
  def ipad?
    !!(request.user_agent.to_s =~ /ipad/i)
  end

  def iphone?
    !!(request.user_agent.to_s =~ /iphone|ipod/i)
  end

  def ios?
    !!(request.user_agent.to_s =~ /ipad|iphone|ipod/i)
  end

  def android_phone?
    !!(request.user_agent.to_s =~ /android.*mobile/i)
  end

  def android_tablet?
    !!(request.user_agent.to_s =~ /android/i && request.user_agent.to_s !~ /mobile/i)
  end

  def phone?
    iphone? || android_phone?
  end

  def tablet?
    ipad? || android_tablet?
  end

  def mobile?
    phone?
  end

  def touchable?
    !!(request.user_agent.to_s =~ /android|ipad|iphone|ipod/i)
  end

  def html5_video_capable?
    !!(request.user_agent.to_s =~ /android|ipad|iphone|ipod/i)
  end

  def html5_audio_capable?
    !!(request.user_agent.to_s =~ /android|ipad|iphone|ipod/i)
  end

  def can_autoplay_video?
    request.user_agent.to_s !~ /android|ipad|iphone|ipod/i
  end

  def forces_video_controls?
    iphone?
  end

  def mobile_safari?
    !!(request.user_agent.to_s =~ /(ipad|iphone|ipod).*applewebkit.*mobile.*safari/i)
  end

  def embedded_webview?
    !mobile_safari? && !!(request.user_agent.to_s =~ /(ipad|iphone|ipod).*applewebkit.*mobile/i)
  end

  def facebook_ios_webview?
    embedded_webview? && !!(request.user_agent.to_s =~ /fbios/i)
  end

  def twitter_webview?
    return session[:twitter_referer] if session[:twitter_referer]
    session[:twitter_referer] = !!request.referer.to_s.downcase.index('t.co')
    embedded_webview? && session[:twitter_referer]
  end

  def chrome_ios_webview?
    embedded_webview? && !!(request.user_agent.to_s =~ /crios/i)
  end

  def mp_browser
    case request.user_agent.to_s.downcase
    when /opera mini/
      'Opera Mini'
    when /opera/
      'Opera'
    when /(blackberry|playbook|bb10)/
      'BlackBerry'
    when /chrome/
      'Chrome'
    when /android/
      'Android Mobile'
    when /apple.*mobile/
      'Mobile Safari'
    when /apple/
      'Safari'
    when /konqueror/
      'Konqueror'
    when /firefox/
      'Firefox'
    when /msie/
      'Internet Explorer'
    when /gecko/
      'Mozilla'
    end
  end

  def mp_os
    case request.user_agent.to_s.downcase
    when /windows.*phone/
      'Windows Mobile'
    when /windows/
      'Windows'
    when /ipad|iphone|ipod/
      'iOS'
    when /android/
      'Android'
    when /blackberry|playbook|bb10/
      'BlackBerry'
    when /mac/
      'Mac OS X'
    when /linux/
      'Linux'
    end
  end

  def mp_device
    case request.user_agent.to_s.downcase
    when /ipod/
      'iPod Touch'
    when /ipad/
      'iPad'
    when /iphone/
      'iPhone'
    when /blackberry|playbook|bb10/
      'BlackBerry'
    when /windows.*phone/
      'Windows Phone'
    when /android/
      'Android'
    end
  end
end
