class Admin::BaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter :admin_required
  before_filter :layout_stuff

  def delayed_jobs
    @delayed_jobs = Delayed::Job.page(params[:page]).per(25)
  end

  private

  def layout_stuff
    @hide_donate_button = true
  end
end
