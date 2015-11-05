module ApplicationHelper
  def page_id
    @page_id ||= controller.controller_name + '_' + controller.action_name
  end

  def partial(page, options={})
    erb page, options.merge!(:layout => false)
  end

  def card_options(name="")
    "<option value=\"visa\">Visa</option>\n" +
      "<option value=\"amex\">American Express</option>\n" +
      "<option value=\"mastercard\">Mastercard</option>"
  end

  def month_options(name="")
    Date::ABBR_MONTHNAMES[1..12].map.with_index { |month, idx|
      "<option value=\"#{idx + 1}\">#{month}</option>"
    }.join("\n")
  end

  def year_options(name="")
    (2012..2020).map { |year|
      "<option value=\"#{year}\">#{year}</option>"
    }.join("\n")
  end

  def meta_tags
    @meta_tags.map { |name, content|
      options = (name =~ /^(og:|fb:)/) ? {property: name, content: content} : {name: name, content: content}
      tag "meta", options
    }.join("\n").html_safe
  end

  def meta_tag(name, content)
    @meta_tags[name] = content
  end

  def donor_count
    number_with_delimiter(Donor.active.count)
  end

  def stripe_fee_amount
    Donation.new(
      donor: Donor.new(add_fee: true, card: DonorCard.new(stripe_card_id: "foo")),
      nonprofits: [Nonprofit.new] * Donation::NUMBER_OF_NONPROFITS,
      donor_card: DonorCard.new(stripe_card_id: 'blah')
    ).calculate_added_fee
  end


  def hide_donate_button_if_donor
    @hide_donate_button = current_donor? && current_donor.active?
  end

  def error_tooltip_for(obj, field, html_options={})
    # Don't show tooltiip if there are no errors or the value is blank
    return "" if obj.errors[field].empty? #|| obj.errors.added?(field, :blank)

    html_options[:style] = [html_options[:style], "color: red"].compact.join('; ')
    html_options[:class] = "small tooltip tooltop-offset t0 r0 mobile-hide"
    html_options[:title] = "<div style='width: 300px'>#{obj.errors.full_messages_for(field).to_sentence}</div>"

    content_tag(:a, html_options) do
      content_tag(:span, "", class: "ss-icon ss-help")
    end
  end

  def default_ref_tag
    controller.controller_name + "_" + controller.action_name
  end

  def tweet_url(options = {})
    share_url(url: tweet(options))
  end

  def tweet(options = {})
    raise unless options[:text] || options[:url]
    options[:related] = (options[:related] ||= "").gsub(/\s/, "").split(",").join(",")
    options.reject! { |k,v| v.blank? }
    return "https://twitter.com/intent/tweet?#{options.to_query}"
  end

  def facebook_share_dialog_url(url: root_url, redirect: root_url)
    fb_params = {
      app_id:       FACEBOOK[:app_id],
      display:      'popup',
      href:         url,
      redirect_uri: redirect
    }
    share_url(url: "https://www.facebook.com/dialog/share?#{fb_params.to_query}")
  end

  # https://coderwall.com/p/d1vplg/embedding-and-styling-inline-svg-documents-with-css-in-rails
  def inline_svg filename, options = {}
    file = File.read(Rails.root.join('app', 'assets', 'images', filename))
    doc = Nokogiri::HTML::DocumentFragment.parse file
    svg = doc.at_css 'svg'
    options.each { |k,v| svg[k.to_s] = v }
    doc.to_html.html_safe
  end

end
