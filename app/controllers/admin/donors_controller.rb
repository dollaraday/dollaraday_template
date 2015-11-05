class Admin::DonorsController < Admin::BaseController
  before_filter :find_donor, only: [:show]

  def index
    @q = Donor.search(params[:q])
    @donors = @q.result(distinct: true).includes(:card, :subscriber)
  end

  def find_donor
    @donor = Donor.find_by_param(params[:id])
  end

  def show
  end

end
