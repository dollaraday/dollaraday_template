class SubscribersController < ApplicationController

  before_action :load_subscriber,                       except: [:new, :create, :thanks]
  before_action -> { require_subscriber(@subscriber) }, except: [:new, :create, :thanks, :email_login, :favorites]

  respond_to :html
  respond_to :js, only: :create

  def show
    # redirect to self without params[:auth] to remove it from the url
    if params[:auth]
      redirect_to subscriber_path(current_subscriber)
    end
  end

  def donations
    @favorite_nonprofits_ids = @subscriber.favorite_nonprofits.pluck(:id)
  end

  def new
    @subscriber = Subscriber.new
    @hide_header = true
    @hide_footer = true
  end

  def create
    @subscriber               = Subscriber.inactive.where(email: subscriber_params[:email]).first_or_initialize(subscriber_params)
    @subscriber.ip_address    = request.ip
    @subscriber.resubscribing = true if @subscriber.persisted?
    set_subscriber_cookie(@subscriber, :signup)

    if @subscriber.save
      session[:thanks] = true
      if request.xhr?
        head 200
      else
        redirect_to thanks_subscribers_url
      end
    else
      if request.xhr?
        render text: "#{@subscriber.errors.full_messages.first}.", status: 400
      else
        render :new
      end
    end
  end

  def thanks
    @hide_header = true
    @hide_footer = true
    redirect_to root_url unless session.delete(:thanks)
  end

  def update
    @current_subscriber.attributes = subscriber_params

    if @current_subscriber.save
      redirect_to subscriber_url(@current_subscriber)
      flash[:notice] = "Your email has been updated"
    else
      render :show
    end
  end

  def unsubscribe
    @current_subscriber.unsubscribe!
    cookies[:unsubscribed] = true
    flash[:notice] = "You've been unsubscribed! Come back here if you change your mind."
    redirect_to subscriber_url(@current_subscriber)
  end

  def resubscribe
    @current_subscriber.resubscribe!
    cookies[:resubscribed] = true
    flash[:notice] = "You've been resubscribed!"

    redirect_to subscriber_url(@current_subscriber)
  end

  def email_login
    set_subscriber_cookie(@subscriber, :email)
    if params[:next] and params[:next] =~ /\A\/[^\/].*\z/
      redirect_to params[:next]
    else
      redirect_to subscriber_path(@subscriber)
    end
  end

  def logout
    unset_subscriber_cookie
    flash[:notice] = "You’ve logged out. See you soon!"
    redirect_to root_url
  end

  protected

  def subscriber_params
    params.require(:subscriber).permit(:name, :email)
  end

  def load_subscriber
    @subscriber = Subscriber.where(params.permit(:guid, :auth_token)).first or redirect_to root_url
  end

end
