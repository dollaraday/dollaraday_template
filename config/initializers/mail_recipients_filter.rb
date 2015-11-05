# Allowed emails for transactional and batch delivery
# Special emails (don't remove):
#   %recipient% — for Mailgun batch delivery
#   @emailtests.com — for Litmus testing

ALLOWED_EMAILS = %w(
  *@*.emailtests.com
)

# Disabling until we have the need for this
unless Rails.env.production? || Rails.env.test?
  ActionMailer::Base.register_interceptor(MailRecipientsFilter)
end
