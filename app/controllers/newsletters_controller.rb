class NewslettersController < ApplicationController
  def preview
    if Nonprofit.is_public.for_today.present?
      @todays_nonprofit = Nonprofit.is_public.for_today
    else
      @todays_nonprofit = Nonprofit.is_public.for_next_possible_day.first || Nonprofit.new(name: "No Nonprofit for Today", blurb: "n/a", description: "n/a", newsletter: Newsletter.new)
    end

    @newsletter = @todays_nonprofit.newsletter

    html = @newsletter.donor_generated || @newsletter.donor_generate
    doc = Nokogiri::HTML(html)

    (doc / "body").first['style'] = "zoom : #{params[:zoom].to_i}%" if params[:zoom].presence
    (doc / "#unsubscribe_link").remove
    (doc / "#view_link").remove
    (doc / "#intro").remove

    render text: doc.to_html
  end

end


