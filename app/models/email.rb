class Email < ActiveRecord::Base
  belongs_to :newsletter
  belongs_to :subscriber
  belongs_to :donor

  validates :subscriber_id,
    uniqueness: { scope: :newsletter_id, if: ->(e) { e.newsletter_id.present? } }
end
