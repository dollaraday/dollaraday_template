module NewslettersHelper

  def login_and_goto(nextpath, *args)
    email_login_subscriber_url("%recipient.guid%", "%recipient.auth_token%", next: Rails.application.routes.url_helpers.send(nextpath, "%recipient.guid%", *args))
  end

  def newsletter_tweet_url(nonprofit, type, double_escape=true)
    # Get the string with variables
    case type.to_sym
    when :donor
      text = t("newsletter.share.twitter.text.donor", nonprofit: nonprofit.twitter_or_name, donors: nonprofit.donations.executed.count)
    when :subscriber
      text = t("newsletter.share.twitter.text.subscriber", nonprofit: nonprofit.twitter_or_name, nonprofit_url: nonprofit_url(nonprofit))
    else
      raise
    end
    tweet_url(text: text, related: nonprofit.twitter)
  end

  def newsletter_gift_tweet_link(nonprofit, double_escape=false, donor)
    days_text = @gift.original_months_remaining.nil? ? "Somebody just signed me up for #{CONFIG[:twitter_username]}" : "Somebody just gave me #{ @days } days of #{CONFIG[:twitter_username]}"
    tweet     = CGI.escape "#{days_text}. I can't wait to discover & support amazing nonprofits: #{CONFIG[:site]}"
    tweet     = CGI.escape(tweet) if double_escape
    tweet_url = URI.escape("#{root_url}share?url=https://twitter.com/intent/tweet?text=#{tweet}")

    link_to "#{image_tag("#{root_url}images/email/icon-twitter-white.png", height: 14)} Tweet".html_safe, tweet_url, target: "_new", style: "background-color: #00aced; padding: 8px 15px; border-radius: 3px; color: #fff; display: inline-block; text-decoration: none; margin-right: 15px;"
  end

  def newsletter_gifter_tweet_link(double_escape=false)
    tweet     = CGI.escape "I just gave the gift of #{CONFIG[:twitter_username]}! You can help others discover amazing nonprofits, too: #{CONFIG[:site]}/gifting"
    tweet     = CGI.escape(tweet) if double_escape
    tweet_url = URI.escape("#{root_url}share?url=https://twitter.com/intent/tweet?text=#{tweet}")

    link_to "#{image_tag("#{root_url}images/email/icon-twitter-white.png", height: 14)} Tweet".html_safe, tweet_url, target: "_new", style: "background-color: #00aced; padding: 8px 15px; border-radius: 3px; color: #fff; display: inline-block; text-decoration: none; margin-right: 15px;"
  end

  def newsletter_fbshare_gifter(double_escape=false)
    fbshare     = "<span style='display:none; display:none !important;'>I just gave the gift of #dollaraday! You can help others discover amazing nonprofits, too: #{CONFIG[:site]}/gifting</span>"
    fbshare     = CGI.escape(fbshare) if double_escape
    fbshare_url = "#{root_url}share?url=https://www.facebook.com/dialog/share?display=popup&app_id=#{FACEBOOK[:app_id]}&href=#{URI.escape(gift_page_url)}&redirect_uri=#{URI.escape(root_url)}&link=#{URI.escape(gift_page_url)}"


    link_to "#{image_tag("#{root_url}images/email/icon-facebook-white.png", height: 14, style: "margin-right: 4px")} Share".html_safe, fbshare_url, target: "_new", style: "background-color: #3B5998; padding: 8px 15px; border-radius: 3px; color: #fff; display: inline-block; text-decoration: none;"
  end

  def newsletter_facebook_url(nonprofit, double_escape=false)
    fb_params = {
      display:      'popup',
      app_id:       FACEBOOK[:app_id],
      redirect_uri: root_url,
      link:         nonprofit_url(nonprofit),
      name:         nonprofit.name,
      description:  t("newsletter.share.facebook.text", donors: nonprofit.donations.executed.count, nonprofit: nonprofit.name),
      catption:     root_url,
      actions:      "[{'link':'#{nonprofit_url(nonprofit)}','name':'#{CONFIG[:name]}'}]"
    }
    share_url(url: "https://www.facebook.com/dialog/feed?#{fb_params.to_query}")
  end

end
