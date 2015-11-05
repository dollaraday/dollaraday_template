require_relative '../test_helper'

class DonationTest < ActiveSupport::TestCase
  subject { Donation.new(donor: FactoryGirl.build(:stripe_donor), guid: "asdf") }

  should belong_to(:donor)
  should belong_to(:donor_card)
  should have_many(:donation_nonprofits)
  should have_many(:nonprofits).through(:donation_nonprofits)

  should validate_presence_of(:scheduled_at)
  should_not validate_presence_of(:nfg_charge_id)
  should "validate uniqueness of guid" do
    existing_donation = FactoryGirl.create(:scheduled_donation, guid: subject.guid)
    assert !subject.valid?
    assert_equal ["has already been taken"], subject.errors[:guid]
  end

  context "an executed donation" do
    subject { FactoryGirl.create(:executed_donation) }

    should validate_presence_of(:nfg_charge_id)
    should "have 30 nonprofits" do
      assert_equal 30, subject.nonprofits.count
    end

    context "and the following pending donation" do
      setup do
        # TODO this destroy the default pending donation from Donor#after_create, ... can we find a way to create
        # an executed donation in factory and skip the default one from Donor#after_create?
        subject.donor.donations.pending.destroy_all

        @pending = FactoryGirl.create(:scheduled_donation, donor: subject.donor, scheduled_at: 30.days.since(subject.scheduled_at).beginning_of_day)
        @pending.donor_card.expects(:cof_exists?).once.returns(true)
        NetworkForGood::CreditCard.expects(:make_cof_donation).with(@pending).once.returns({charge_id: "123"})
        @pending.execute!
      end

      should "have 30 nonprofits" do
        assert_equal 30, subject.nonprofits.count
      end
    end

    context "and the following pending donation with overlapping nonprofits" do
      setup do
        # TODO this destroy the default pending donation from Donor#after_create, ... can we find a way to create
        # an executed donation in factory and skip the default one from Donor#after_create?
        subject.donor.donations.pending.destroy_all

        # Using 29 to demonstrate the 1 overlapping nonprofit
        @pending = FactoryGirl.create(:scheduled_donation, donor: subject.donor, scheduled_at: 29.days.since(subject.scheduled_at).beginning_of_day)
        @pending.donor_card.expects(:cof_exists?).once.returns(true)
        NetworkForGood::CreditCard.expects(:make_cof_donation).with(@pending).never
      end

      should "raise error when executing" do
        assert_raises(Donation::OverlappingDonationNonprofits) {
          @pending.execute!
        }
      end
    end
  end

  context "a gifted donation" do
    setup do
      @donation = FactoryGirl.create(:scheduled_donation, scheduled_at: Time.now)
      @gift = FactoryGirl.create(:gift, donor: @donation.donor)
      @donation = @gift.donor.donations.pending.first
    end

    context "with 1 month left" do
      context "executing" do
        setup do
          NetworkForGood::CreditCard.expects(:make_cof_donation).with(@donation).once.returns({charge_id: "123"})
          DonorCard.any_instance.expects(:cof_exists?).once.returns(true)
          @donation.execute!
        end

        should_change "gift months remaining", by: -1 do @gift.reload.months_remaining end
        should_change "executed?", to: true do @donation.executed? end
      end
    end

    context "with 0 months left" do
      setup do
        @gift.update_column(:months_remaining, 0)
      end

      context "executing" do
        setup do
          NetworkForGood::CreditCard.expects(:make_cof_donation).never
          DonorCard.any_instance.expects(:cof_exists?).once.returns(true)
          @donation.expects(:fail!).with("Donation::ExpiredGift", notify_donor: false)
        end

        should "raise error" do
          @donation.execute!
          @donation.reload

          assert_equal nil, @donation.nfg_charge_id
          assert_equal 0, @donation.nonprofits(true).count
          assert_equal 0.0, @donation.amount.to_f
          assert_equal 0.0, @donation.added_fee.to_f
          assert_nil @donation.executed_at
        end
      end
    end

    context "with infinite" do
      setup { @gift.update_column(:months_remaining, nil) }
      context "executing" do
        setup do
          NetworkForGood::CreditCard.expects(:make_cof_donation).with(@donation).once.returns({charge_id: "123"})
          DonorCard.any_instance.expects(:cof_exists?).once.returns(true)
          @donation.execute!
        end

        should_not_change "gift months remaining" do @gift.reload.months_remaining end
        should_change "executed?", to: true do @donation.executed? end
      end
    end
  end

  context "an NFG donation" do
    setup { @donation = FactoryGirl.create(:scheduled_donation) }

    context "locking and executing" do
      setup { @donation.lock_and_execute! }

      should_delay_job "ExecuteDonationJob"
      should_change "lock", from: nil do @donation.locked_at end
    end

    context "executing" do
      setup do
        NetworkForGood::CreditCard.expects(:make_cof_donation).with(@donation).once.returns({charge_id: "123"})
        DonorCard.any_instance.expects(:cof_exists?).once.returns(true)
        @donation.execute!
      end

      should_change "nfg_charge_id", to: "123" do @donation.reload.nfg_charge_id end
      should_change "donation's nonprofits", from: 0, to: 30 do
        @donation.nonprofits(true).count
      end
      should "set donation's nonprofits correctly" do
        assert_equal @donation.nonprofits, @donation.scheduled_nonprofits
      end
      should "set donation's donation_nonprofits' dates" do
        assert_equal @donation.donation_nonprofits(true).map(&:donation_on), @donation.nonprofits.map(&:featured_on)
      end
      should_change "donation's amount", from: 0.0, to: 30.0 do @donation.reload.amount.to_f end
      should_not_change "donation's added_fee" do @donation.reload.added_fee.to_f end
      should_change "executed_at" do @donation.reload.executed_at end
    end

    context "executing with added fee" do
      setup do
        @donation.donor.update_column(:add_fee, true)
        @donation.reload
        NetworkForGood::CreditCard.expects(:make_cof_donation).with(@donation).once.returns({charge_id: "123"})
        DonorCard.any_instance.expects(:cof_exists?).once.returns(true)
        @donation.execute!
      end

      should_change "nfg_charge_id", to: "123" do @donation.reload.nfg_charge_id end
      should_change "donation's nonprofits", from: 0.0, to: 30 do @donation.nonprofits(true).count end
      should_change "donation's amount", from: 0.0, to: 30.0 do @donation.reload.amount.to_f end
      should_change "donation's added_fee", from: 0.0, to: 1.2 do @donation.reload.added_fee.to_f end
      should_change "executed_at" do @donation.reload.executed_at end
    end

    context "executing without a COF" do
      setup do
        NetworkForGood::CreditCard.expects(:make_cof_donation).never
        @donation.donor_card.expects(:cof_exists?).once.returns(false)
        @donation.expects(:fail!).with("Donation::NoAvailableCOF", notify_donor: true)
      end

      should "raise error" do
        @donation.execute!
        @donation.reload

        assert_equal nil, @donation.nfg_charge_id
        assert_equal 0, @donation.nonprofits(true).count
        assert_equal 0.0, @donation.amount.to_f
        assert_equal 0.0, @donation.added_fee.to_f
        assert_nil @donation.executed_at
      end
    end

    context "executing and getting an NFG error" do
      setup do
        error_response = [{error_details: {error_info: {err_code: "NpoNotEligible", err_data: "some error"}}}]
        NetworkForGood::CreditCard.expects(:make_cof_donation).with(@donation).once.returns(error_response)
        @donation.donor_card.expects(:cof_exists?).once.returns(true)
        @donation.expects(:fail!).with(error_response.to_s, notify_donor: false)
      end

      should "raise error" do
        @donation.execute!
        @donation.reload

        assert_equal nil, @donation.nfg_charge_id
        assert_equal 30, @donation.nonprofits(true).count
        assert_equal 0.0, @donation.amount.to_f
        assert_equal 0.0, @donation.added_fee.to_f
        assert_nil @donation.executed_at
      end
    end
  end

  context "a Stripe donation" do
    setup do
      @donation = FactoryGirl.create(:scheduled_donation, donor: FactoryGirl.build(:stripe_donor))
    end

    context "locking and executing" do
      setup { @donation.lock_and_execute! }

      should_delay_job "ExecuteDonationJob"
      should_change "lock", from: nil do @donation.locked_at end
    end

    context "executing" do
      setup do
        @donation.execute!
      end

      should_change "stripe_charge_id", from: nil, to: /test_ch_\d/ do @donation.reload.stripe_charge_id end
      should_change "donation's nonprofits", from: 0, to: 30 do
        @donation.nonprofits(true).count
      end
      should "set donation's nonprofits correctly" do
        assert_equal @donation.nonprofits, @donation.scheduled_nonprofits
      end
      should "set donation's donation_nonprofits' dates" do
        assert_equal @donation.donation_nonprofits(true).map(&:donation_on), @donation.nonprofits.map(&:featured_on)
      end
      should_change "donation's amount", from: 0.0, to: 30.0 do @donation.reload.amount.to_f end
      should_not_change "donation's added_fee" do @donation.reload.added_fee.to_f end
      should_change "executed_at" do @donation.reload.executed_at end
    end

    context "executing with added fee" do
      setup do
        @donation.donor.update_column(:add_fee, true)
        @donation.reload
        @donation.execute!
      end

      should_change "stripe_charge_id", from: nil, to: /test_ch_\d/ do @donation.reload.stripe_charge_id end
      should_change "donation's nonprofits", from: 0.0, to: 30 do @donation.nonprofits(true).count end
      should_change "donation's amount", from: 0.0, to: 30.0 do @donation.reload.amount.to_f end
      should_change "donation's added_fee", from: 0.0, to: 1.20 do @donation.reload.added_fee.to_f end
      should_change "executed_at" do @donation.reload.executed_at end

      # NB this is mostly a sanity check to make sure our calculation scales up
      context "calculating fee for a $60 donation" do
        setup { @donation.stubs(:calculate_amount).returns(60.0) }
        should "return correct fee" do assert_equal 2.10, @donation.calculate_added_fee.round(2) end
      end

      context "calculating fee for a $120 donation" do
        setup { @donation.stubs(:calculate_amount).returns(120.0) }
        should "return correct fee" do assert_equal 3.89, @donation.calculate_added_fee.round(2) end
      end

      context "calculating fee for a $1000 donation" do
        setup { @donation.stubs(:calculate_amount).returns(1000.0) }
        should "return correct fee" do assert_equal 30.18, @donation.calculate_added_fee.round(2) end
      end
    end

    context "executing and getting a card error" do
      setup do
        StripeMock.prepare_card_error(:card_declined)
        @donation.expects(:fail!)
      end

      should "raise error" do
        @donation.execute!
        @donation.reload

        assert_equal nil, @donation.stripe_charge_id
        assert_equal 30, @donation.nonprofits(true).count
        assert_equal 0.0, @donation.amount.to_f
        assert_equal 0.0, @donation.added_fee.to_f
        assert_nil @donation.executed_at
      end
    end
  end


end
