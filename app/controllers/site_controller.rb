class SiteController < ApplicationController

  before_filter :authenticate_user!

  def index
    today = Time.zone.now
    @dates = {
      "Today" => today.strftime("%Y-%m-%d"),
      "Tomorrow" => (today + (3600 * 24)).strftime("%Y-%m-%d"),
      "Day After Tomorrow" => (today + (3600 * 24 * 2)).strftime("%Y-%m-%d")
    }
    @nonprofits = Nonprofit.is_public.featured_from(Time.zone.now.to_date + 1.day).limit(16)

    if Nonprofit.is_public.for_today.present?
      @todays_nonprofit = Nonprofit.is_public.for_today
    else
      @todays_nonprofit = Nonprofit.is_public.for_next_possible_day.first || Nonprofit.new(name: "No Nonprofit for Today", blurb: "n/a", description: "n/a", newsletter: Newsletter.new)
    end

    @subscriber = Subscriber.new
  end

  def donate
  end

  def wall_calendar
  end

  def legal
  end

  def faq
  end

  def contact
  end

  def send_feedback
    params[:email] = params[:email].to_s
    params[:message] = params[:message].to_s

    if params[:email] !~ Devise.email_regexp
      flash[:alert] = "Please enter a valid email address."
      render :contact
    elsif params[:message].blank?
      flash[:alert] = "Please enter a message to send."
      render :contact
    else
      SendFeedbackJob.new(params[:email], params[:message]).save
      flash[:notice] = "Thanks! We'll look at your message in a bit."
      redirect_to root_url
    end
  end

  def calendar
    @page_title = "Calendar"

    # TODO better solution than a rescue fallback here
    @date = Date.parse(params[:date]) rescue Date.today
    @future_nonprofits = Nonprofit.is_public.featured_from(@date).limit(31)
    @past_nonprofits = Nonprofit.is_public.featured_reverse_from(@date).limit(1)

    @subscriber = Subscriber.new
  end

  def share
    @full_url = params[:url]
    if @full_url
      @full_url += "&"
    else
      @full_url = [root_url, '?'].join('') if !@full_url
    end
    params.each do |k,v|
        @full_url += "#{k}=#{v}&" if ["redirect_uri", "href", "app_id", "display"].include?(k)
    end
    render :layout => false
  end
end
