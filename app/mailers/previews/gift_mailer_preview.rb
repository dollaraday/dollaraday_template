class GiftMailerPreview < ActionMailer::Preview
  def giver_confirmation
    @gift = Gift.first
    GiftMailer.giver_confirmation(@gift.id)
  end

  def recipient_initial
    @gift = Gift.first
    GiftMailer.recipient_initial(@gift.id)
  end

  def recipient_reminder
    @gift = Gift.first
    GiftMailer.recipient_reminder(@gift.id)
  end
end
