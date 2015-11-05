class GiftMailer < BaseMailer
  helper :nonprofits

  def giver_confirmation(gift_id)
    @newsletter_type = :giver
    @gift = Gift.find(gift_id)
    @subscriber = @gift.giver_subscriber

    mail(to: @gift.giver_subscriber.email, subject: "Thanks for giving the gift of #{CONFIG[:name]}!") do |format|
      format.html { render layout: "gift" }
    end
  end

  def recipient_initial(gift_id)
    @newsletter_type = :recipient
    @gift = Gift.find(gift_id)
    @donor = @gift.donor
    @subscriber = @donor.subscriber
    @newsletter = Nonprofit.for_today.newsletter

    mail(to: @donor.subscriber.email, subject: "Amazing nonprofits will be supported in your name!") do |format|
      format.html { render layout: "gift" }
    end
  end

  def recipient_reminder(gift_id)
    @newsletter_type = :recipient
    @gift = Gift.find(gift_id)
    @donor = @gift.donor
    @subscriber = @donor.subscriber
    @days = @gift.original_months_remaining * 30

    mail(to: @donor.subscriber.email, subject: "Your #{@days} days of #{CONFIG[:name]} are almost up!") do |format|
      format.html { render layout: "gift" }
    end
  end
end
