ActionMailer::Base.register_interceptor(MailSubjectsFilter) unless Rails.env.production?
