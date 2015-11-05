# encoding: UTF-8
module NonprofitsHelper

  def share_twitter_link_to(*args, &block)
    if block_given?
      nonprofit = args[0]
      args[0] = ''
      html_options = (args[1] ||= {})
    else
      nonprofit = args[1]
      args[1] = ''
      html_options = (args[2] ||= {})
    end

    text = ERB::Util.url_encode("I just found an amazing nonprofit #{nonprofit.twitter_or_name} on #{CONFIG[:twitter_username]}. Learn more: #{nonprofit_url(nonprofit)}")
    html_options[:href] = URI.escape("#{root_url}share?url=https://twitter.com/intent/tweet?text=#{text}")
    html_options[:rel] = 'nofollow'

    link_to(*args, &block)
  end


  # DOC: https://developers.facebook.com/docs/sharing/reference/feed-dialog/v2.2?locale=en_IN
  def share_facebook_link_to(*args, &block)
    if block_given?
      nonprofit = args[0]
      args[0] = ''
      html_options = (args[1] ||= {})
    else
      nonprofit = args[1]
      args[1] = ''
      html_options = (args[2] ||= {})
    end

    url = ERB::Util.url_encode(nonprofit_url(nonprofit))
    title = ERB::Util.url_encode(nonprofit.name)
    actions = "[{'link':'#{url}','name':'#{CONFIG[:name]}'}]"
    html_options[:href] = "#{root_url}share?url=https://www.facebook.com/dialog/feed?"\
                          "display=popup"\
                          "&app_id=#{FACEBOOK[:app_id]}"\
                          "&redirect_uri=#{root_url}"\
                          "&link=#{url}"\
                          "&caption=#{title} on #{CONFIG[:name]}"\
                          "&name=#{title} on #{CONFIG[:name]}"\
                          "&actions=#{actions}"
    html_options[:rel] = 'nofollow'

    link_to(*args, &block)
  end

  def url_without_protocol(url)
    url.to_s.sub(/^https?\:\/\//, '').sub(/^www./, '').sub(/\/$/, '')
  end

  def link_to_nonprofit(nonprofit, opts={})
    url = url_without_protocol(nonprofit.website_url)
    link_to url, "http://#{url}", opts
  end
end
