class ApplicationController < ActionController::Base
  include DeviceIdioms
  include AuthenticationConcerns
  include ActionView::Helpers::AssetUrlHelper

  protect_from_forgery
  before_filter :extra_logging
  before_filter :default_meta_tags
  before_filter :tweak_headers
  before_filter :set_theme

  helper_method :auth_method
  helper_method :current_subscriber, :current_subscriber?, :current_donor, :current_donor?
  helper_method :mobile?

  protected

  def tweak_headers
    # Rails 4 added this by default, but it makes the site unembeddable in
    # StumbleUpon. Can't think of a reason to keep it for DaD.
    response.headers.delete("X-Frame-Options")
  end

  def set_theme
    @theme = 'light'
  end

  def initialize_donor
    @donor = Donor.new
    @subscriber = @donor.build_subscriber
    @subscriber.donor = @donor
    @donor.started_on = Time.zone.now.to_date
  end

  def initialize_gift
    initialize_donor
    @gift = Gift.new(donor: @donor)
    @donor.gift = @gift # for some reason inverse_of wasn't triggering when donor is a form builder?
    @gift.start_on = Time.zone.now.to_date
  end

  # orz
  def extra_logging
    Rails.logger.info "  UA: #{request.user_agent}"
    Rails.logger.info "  RF: #{request.headers["Referer"] || "none"}"
  end

  def default_meta_tags
    @meta_tags ||= {}
    @meta_tags['fb:app_id']       = FACEBOOK[:app_id]
    @meta_tags['og:url']          = "#{root_url}"
    @meta_tags['og:type']         = "website"
    @meta_tags['og:site_name']    = CONFIG[:name]
    @meta_tags['og:title']        = CONFIG[:name]
    @meta_tags['og:image']        = view_context.image_path "facebook-avatar.jpg"
    @meta_tags['og:image:secure_url'] = view_context.image_path "facebook-avatar.jpg"
    @meta_tags['og:description']  = CONFIG[:description]
  end

  def current_subscriber(force = false)
    if (!defined? @current_subscriber) || force
      @current_subscriber = load_current_subscriber
    end
    @current_subscriber
  end

  def current_subscriber?
    current_subscriber.present?
  end

  def current_donor
    @current_donor ||= current_subscriber.try(:donor)
  end

  def current_donor?
    current_donor.present?
  end

  def require_subscriber(specific = nil)

    logger.debug "Requiring subscriber"

    if current_subscriber?
      case specific
      when NilClass
        return true
      when Subscriber
        return true if current_subscriber == specific
      when String
        return true if current_subscriber == Subscriber.find_by_guid(specific)
      else
        return true
      end
    end

    respond_to do |format|
      format.html do
        flash[:error] = "Bad url! Try again, or contact us for help."
        redirect_to root_url
      end
    end

  end

  def require_donor
    return true if current_donor

    respond_to do |format|
      format.html do
        flash[:error] = "We couldn't find that donor! Try again, or contact us for help."
        redirect_to root_url
      end
      format.json do
        render json: {
          success: false,
          message: "We couldn't find a donor with those credentials! Try again, or contact us for help."
        }
      end
    end
  end

  def load_current_subscriber
    subscriber = nil

    if cookies.encrypted[:subscriber_guid].present?
      subscriber = Subscriber.where(guid: cookies.encrypted[:subscriber_guid]).first
    elsif params[:guid] && params[:auth]
      subscriber = Subscriber.where(guid: params[:guid], auth_token: params[:auth]).first
      set_subscriber_cookie(subscriber, :token) if subscriber.present?
    end

    subscriber
  end

  # Verify donor, and login temporarily
  def verify_donor # {email: '*@*.com', last_4: '1234', exp_month: '4', exp_year: '2014'}
    if auth = params[:donor_verification]
      subscriber  = Subscriber.where(email: auth[:email].to_s).includes(:donor).first
      donor       = subscriber.try(:donor)
      if donor && donor.card && (Rails.env.development? || donor.card.valid_credentials?(auth[:last_4], auth[:exp_month], auth[:exp_year]))
        @current_subscriber = subscriber
        set_subscriber_cookie(@current_subscriber, (Rails.env.development? ? :development : :card))
        true
      else
        false
      end
    else
      false
    end
  end

  def set_subscriber_cookie subscriber, auth_method, expires: 30.days.from_now
    is_secure = Rails.env.production? || Rails.env.staging?
    cookies.encrypted[:subscriber_guid]   = { value: subscriber.guid,   expires: expires, httponly: true, secure: is_secure }
    cookies.encrypted[:auth_method]       = { value: auth_method.to_s,  expires: expires, httponly: true, secure: is_secure }
  end

  def unset_subscriber_cookie
    cookies.delete :subscriber_guid
    cookies.delete :auth_method
  end

  def auth_method
    return nil unless current_subscriber?
    if cookies.encrypted[:subscriber_guid].present?
      if cookies.encrypted[:auth_method].present?
        # Return the auth_method cookie if present
        return cookies.encrypted[:auth_method].to_sym
      else
        # Old cookies don't have a auth_method cookie
        return :card
      end
    else
      return :token
    end
  end

end
