require_relative '../test_helper'

class DonorTest < ActiveSupport::TestCase
  context "a donor" do
    subject { Donor.new }

    should have_many(:donations)
    should have_many(:cards)
    should have_one(:card)
    should belong_to(:gift)
    should belong_to(:subscriber)
  end

  context "a new nfg donor" do
    subject { FactoryGirl.build(:nfg_donor) }

    context "saving" do
      setup { subject.save! }

      should "set default nfg_donor_token" do assert_equal 64, subject.nfg_donor_token.length end
      should "set default started_on" do assert_equal Time.zone.now.to_date, subject.started_on end
      should "set default guid" do assert_equal 32, subject.guid.length end
      should "set subscriber" do
        assert subject.subscriber.present?
        assert_in_delta Time.zone.now, subject.subscriber.subscribed_at, 1.second
        assert_equal subject.card.name, subject.subscriber.name
        assert_equal subject.card.email, subject.subscriber.email
        assert_equal "1.1.1.1", subject.subscriber.ip_address
      end
    end

    should "validate uniqueness of guid" do
      existing_donor = FactoryGirl.create(:stripe_donor, guid: subject.guid)
      assert !subject.valid?
      assert_equal ["has already been taken"], subject.errors[:guid]
    end

    context "creating" do
      setup { subject.save! }

      should_change "Donors", by: 1 do Donor.count end
      should "schedule first donation" do
        donation = subject.donations.first
        assert donation.pending?
        assert_equal Time.now.change(usec: 0), donation.scheduled_at.change(usec: 0)
      end
    end
  end


  context "a new stripe donor" do
    subject { FactoryGirl.build(:stripe_donor) }

    context "saving" do
      setup { subject.save! }

      should "set default started_on" do assert_equal Time.zone.now.to_date, subject.started_on end
      should "set default guid" do assert_equal 32, subject.guid.length end
      should "set subscriber" do
        assert subject.subscriber.present?
        assert_in_delta Time.zone.now, subject.subscriber.subscribed_at, 1.second
        assert_equal subject.card.name, subject.subscriber.name
        assert_equal subject.card.email, subject.subscriber.email
        assert_equal "1.1.1.1", subject.subscriber.ip_address
      end
    end

    should "validate uniqueness of guid" do
      existing_donor = FactoryGirl.create(:stripe_donor, guid: subject.guid)
      assert !subject.valid?
      assert_equal ["has already been taken"], subject.errors[:guid]
    end

    should "validate uniqueness of subscriber" do
      existing_donor = FactoryGirl.create(:stripe_donor, subscriber: subject.subscriber)
      assert !subject.valid?
      assert_equal ["has already been taken"], subject.errors[:subscriber]
    end

    context "creating" do
      setup { subject.save! }

      should_change "Donors", by: 1 do Donor.count end
      should "schedule first donation" do
        donation = subject.donations.first
        assert donation.pending?
        assert_equal Time.now.change(usec: 0), donation.scheduled_at.change(usec: 0)
      end
    end
  end

  context "a donor, an active cancelled donor, and an inactive cancelled donor" do
    setup do
      @donor = FactoryGirl.create(:stripe_donor)
      @active_cancelled_donor = FactoryGirl.create(:active_cancelled_donor)
      @inactive_cancelled_donor = FactoryGirl.create(:inactive_cancelled_donor)
    end

    should "return active" do
      assert_equal [@donor, @active_cancelled_donor], Donor.active
    end
  end

  context "an active donor" do
    setup do
      @donor = FactoryGirl.create(:stripe_donor)
      @executed_donation = FactoryGirl.create(:executed_donation, donor: @donor, scheduled_at: 20.days.ago, executed_at: 20.days.ago)
      @pending_donation = @donor.donations.pending.first  # the auto-created one
      @pending_donation.update_column :scheduled_at, 10.days.from_now
    end

    context "cancelling" do
      setup { @donor.cancel! }

      should_change "pending donations", by: -1 do @donor.donations(true).pending.count end
      should_change "cancelled donations", by: 1 do @donor.donations(true).cancelled.count end
      should "set cancelled_at" do assert_equal Time.now.change(usec: 0), @donor.reload.cancelled_at.change(usec: 0) end
      should "set uncancelled_at" do assert_nil @donor.reload.uncancelled_at end
      should_not_change "finished_on" do @donor.reload.finished_on end
      should_delay_job "SendCancelledJob"

      context "then finish_cancelled_donors before period ends" do
        setup do
          Timecop.freeze(@donor.last_executed_donation.executed_at + 29.days)
          Donor.finish_cancelled_donors
        end
        should_not_change "finished_on" do @donor.reload.finished_on end
      end

      context "then finish_cancelled_donors after period ends" do
        setup do
          Timecop.freeze(@donor.last_executed_donation.executed_at + 31.days)
          Donor.finish_cancelled_donors
        end
        should "set finished_on" do assert_equal Time.zone.now.to_date, @donor.reload.finished_on end
        should_change "active card", to:nil do @donor.card(true) end
      end
    end
  end

  # TODO also test an active cancelled donor who finishes, say, 10 days from now (so that the next donation runs 40 days from now)
  context "an inactive donor" do
    setup do
      @inactive_cancelled_donor = FactoryGirl.create(:inactive_cancelled_donor)
    end

    context "uncancelling" do
      setup do
        @inactive_cancelled_donor.uncancel!
      end

      should_change "finished_on", to: nil do @inactive_cancelled_donor.finished_on end
      should_change "pending donations", by: 1 do @inactive_cancelled_donor.donations.pending.count end
      should "schedule a new pending donation" do
        assert_equal Time.now.beginning_of_day, @inactive_cancelled_donor.donations.pending.last.scheduled_at.change(usec: 0)
      end
      should_delay_job "SendUncancelledJob"
    end
  end

  context "an active donor" do
    setup do
      @donation = FactoryGirl.create(:executed_donation)
      @nonprofit = @donation.nonprofits.first
      @donor = @donation.donor
    end

    should "not have duplicates" do refute @donor.has_duplicates? end

    context "with a duplicate donation" do
      setup do
        DonationNonprofit.create!(nonprofit_id: @nonprofit.id, donation_id: @donation.id)
      end

      should "have duplicates" do assert @donor.has_duplicates? end
    end

     context "with a special case duplicate donation (Nonprofit #225)" do
        setup do
          @donor.stubs(:special_case_duplicate_donation_nonprofit_ids).returns([@nonprofit.id])
          DonationNonprofit.create!(nonprofit_id: @nonprofit.id, donation_id: @donation.id)
        end

        should "have duplicates" do refute @donor.has_duplicates? end
      end
  end

end
