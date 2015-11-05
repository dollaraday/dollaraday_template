module AuthenticationConcerns
  extend ActiveSupport::Concern

  def admin_required
    unless current_user && current_user.is_admin
      redirect_to root_url # devise shortcut for this?
    end
  end

end