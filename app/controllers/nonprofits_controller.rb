class NonprofitsController < ApplicationController
  before_filter :find_nonprofit, only: [:show]
  before_filter :page_meta_tags, only: [:show]

  respond_to :html, except: [:upcoming_report]
  respond_to :json, only: [:upcoming_report]

  def index
    redirect_to calendar_url
  end

  def show
    @current_nonprofit = Nonprofit.is_public.find_by_param(params[:id]).featured_on
    @next_day = Nonprofit.is_public.featured_from(@current_nonprofit.next_day).first
    @previous_day = Nonprofit.is_public.featured_reverse_from(@current_nonprofit.prev_day).first

    @hide_header = true
    if current_subscriber?
      @nonprofit_is_favorite = current_subscriber.favorite_nonprofits.exists?(@nonprofit)
      @hide_plane = true
    else
      @hide_footer = true
    end
  end

  protected

  def find_nonprofit
    @nonprofit = Nonprofit.is_public.find_by_param(params[:id])
  end

  def page_meta_tags
    @meta_tags["og:title"]            = @nonprofit.name
    @meta_tags["og:image"]            = @nonprofit.photo.url(:full)
    @meta_tags["og:url"]              = nonprofit_url(@nonprofit)
    @meta_tags["og:description"]      = @nonprofit.blurb

    @meta_tags["twitter:card"]        = "summary_large_image"
    @meta_tags["twitter:title"]       = "#{CONFIG[:name]} Nonprofit for #{@nonprofit.featured_on.try(:to_s, :short_name)}: #{@nonprofit.name}"
    @meta_tags["twitter:image:src"]   = "#{@nonprofit.photo.url(:medium).gsub(/https/, 'http')}"
    @meta_tags["twitter:description"] = @nonprofit.blurb
  end
end
