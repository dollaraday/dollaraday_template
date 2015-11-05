require_relative '../test_helper'

class NonprofitTest < ActiveSupport::TestCase

  should have_many(:donation_nonprofits)
  should have_many(:donations)
  should have_one(:newsletter)

  should validate_presence_of(:name)
  should validate_uniqueness_of(:slug).allow_nil.with_message(/is already used by another Nonprofit/)
  should validate_uniqueness_of(:featured_on).with_message(/is already taken by another Nonprofit/)
  should validate_presence_of(:blurb)

  should "validate editability" do
    nonprofit = FactoryGirl.create(:past_nonprofit)
    nonprofit.description = "A new description."

    assert !nonprofit.valid?
    assert "has been featured and is not editable anymore.".in?(nonprofit.errors[:base])
  end

  should "validate donatability" do
    nonprofit = FactoryGirl.build(:invalid_nonprofit)

    assert !nonprofit.valid?
    assert "NFG error: some error".in?(nonprofit.errors[:ein])
  end

  context "a valid nonprofit" do
    setup { @nonprofit = FactoryGirl.build(:upcoming_nonprofit) }

    context "creating" do
      setup { @nonprofit.save! }

      should_change "nonprofits", by: 1 do Nonprofit.count end
      should_change "newsletters", by: 1 do Newsletter.count end
      should "attach newsletter" do assert_equal Newsletter.last, @nonprofit.newsletter end
      should "be valid" do assert @nonprofit.valid? end
    end

    context "creating with html tags in the description" do
      setup do
        @nonprofit.description = '<b> </b> <i> </i> <a href="" onclick="alert(0)"> </a> <br> </br> <p> </p> <h1> </h1> <script> </script>'
        @nonprofit.save!
      end

      should "sanitize description" do
        assert_equal '<b> </b> <i> </i> <a href=""> </a> <br> </br> <p> </p>   ', @nonprofit.description
      end
    end
  end

  context "a calendar of nonprofits" do
    setup do
      @yesterday = FactoryGirl.create(:past_nonprofit, featured_on: Time.zone.now.to_date - 1)
      @today     = FactoryGirl.create(:current_nonprofit, featured_on: Time.zone.now.to_date)
      @tomorrow  = FactoryGirl.create(:upcoming_nonprofit, featured_on: Time.zone.now.to_date + 1)
    end

    should "return nonprofits featured from" do
      assert_equal [@today, @tomorrow], Nonprofit.featured_from(Time.zone.now.to_date)
    end

    should "return nonprofits featured reverse from" do
      assert_equal [@today, @yesterday], Nonprofit.featured_reverse_from(Time.zone.now.to_date)
    end
  end

end
