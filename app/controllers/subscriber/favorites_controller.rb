class Subscriber::FavoritesController < ApplicationController
  include SubscriberConcerns

  before_action :load_subscriber
  before_action -> { require_subscriber(@subscriber) }, except: [:index]

  def create
    begin
      @nonprofit = Nonprofit.find(params[:id])
      @favorites_diff = 0
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.html { redirect_to subscriber_path(@subscriber), alert: t('favoriting.add.flash.error') }
        format.js   { render js: '', status: 400 }
      end
    else
      exists = @subscriber.favorite_nonprofits.where(id: @nonprofit.id).any?
      if !exists
        @subscriber.favorite_nonprofits << @nonprofit
        @favorites_diff = 1
      end
      respond_to do |format|
        format.js
        format.html {
          notice = exists ? t('favoriting.add.flash.redundant', name: @nonprofit.name) : t('favoriting.add.flash.success', name: @nonprofit.name)
          redirect_to subscriber_favorites_path(@subscriber), notice: notice
        }
      end
    end
  end

  def destroy
    begin
      @nonprofit = Nonprofit.find(params[:id])
      @favorites_diff = 0
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.html { redirect_to subscriber_path(@subscriber), alert: t('favoriting.remove.flash.error') }
        format.js   { render js: '', status: 400 }
      end
    else
      exists = @subscriber.favorite_nonprofits.where(id: @nonprofit.id).any?
      if exists
        Favorite.where(subscriber_id: @subscriber.id, nonprofit_id: @nonprofit.id).destroy_all
        @favorites_diff = -1
      end
      respond_to do |format|
        format.js
        format.html {
          notice = exists ? t('favoriting.remove.flash.success', name: @nonprofit.name) : t('favoriting.remove.flash.redundant', name: @nonprofit.name)
          redirect_to subscriber_favorites_path(@subscriber), notice: notice
        }
      end
    end
  end

  def index

    if current_subscriber? && current_subscriber == @subscriber
      render :index
    else
      render :public, layout: "public"
    end

  end
end
