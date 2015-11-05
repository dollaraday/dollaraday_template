class BaseMailer < ActionMailer::Base
  helper ApplicationHelper, NewslettersHelper

  prepend_view_path Rails.root.join('app/mailers/views')
  layout "base"

  FROM = "#{CONFIG[:name]} <hello@#{CONFIG[:host]}>"

  default from: FROM

end
