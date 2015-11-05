class Admin::DonationsController < Admin::BaseController
  def index
    @donations = Donation.all
  end

end
