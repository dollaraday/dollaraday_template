require_relative '../test_helper'

class DonorCardTest < ActiveSupport::TestCase

  context "a new donor" do
    subject do
      FactoryGirl.create(:stripe_donor).card
    end

    should belong_to(:donor)
    should have_many(:donations)

    should allow_value('test@gmail.com').for(:email)
    should_not allow_value("test@gmail").for(:email)
    should_not allow_value('').for(:email)

    should ensure_length_of(:name).is_at_least(2)

    context "creating" do
      setup { subject.donor.save! }

      should_change "DonorCard", by: 1 do DonorCard.count end
    end
  end

  context "an nfg donor" do
    subject do
      FactoryGirl.build(:nfg_donor).card
    end

    should ensure_length_of(:address1).is_at_least(3).is_at_most(100)
    should validate_presence_of(:city)
    should validate_presence_of(:state)
    should validate_presence_of(:country) #.in_array(%w(US))
    should validate_presence_of(:zip)
    should allow_value('Visa').for(:card_type)
    should allow_value('Mastercard').for(:card_type)
    should allow_value('Amex').for(:card_type)
    should_not allow_value('DinersClub').for(:card_type)
    should allow_value(12).for(:exp_month)
    should_not allow_value(123).for(:exp_month)
    should allow_value(2014).for(:exp_year)
    should_not allow_value(20632).for(:exp_year)
    should allow_value(123).for(:csc)
    should_not allow_value("abc").for(:csc)

    # Example card numbers taken from http://www.paypalobjects.com/en_US/vhelp/paypalmanager_help/credit_card_numbers.htm
    should allow_value("378282246310005").for(:card_number) # amex
    should allow_value("371449635398431").for(:card_number) # amex
    should allow_value("4111111111111111").for(:card_number) # visa
    should allow_value("4012888888881881").for(:card_number) # visa
    should allow_value("5555555555554444").for(:card_number) # mc
    should allow_value("5105105105105100").for(:card_number) # mc

    context "checking cof_exists?" do
      context "with existing COF" do
        setup do
          NetworkForGood::CreditCard.expects(:get_donor_co_fs).once.returns({
            :cards => { :cof_record=> { :cof_id => subject.nfg_cof_id } }
          })
        end
        should "return true" do assert subject.cof_exists? end
      end

      context "with missing COF" do
        setup do
          NetworkForGood::CreditCard.expects(:get_donor_co_fs).once.returns({
            :cards => nil
          })
        end
        should "return false" do refute subject.cof_exists? end
      end
    end
  end

end
