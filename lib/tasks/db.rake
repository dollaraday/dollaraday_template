namespace :db do
  desc "Drop, Create, Migrate and Seed your database"
  task recreate: :environment do
    ENV['RAILS_ENV'] ||= Rails.env

    throw "You're trying to reset db in production!!!" if ENV['RAILS_ENV'] == 'production'

    puts "Dropping database..."
    Rake::Task["db:drop"].invoke
    puts "Creating database..."
    Rake::Task["db:create"].invoke
    puts "Migrating database..."
    Rake::Task["db:migrate"].invoke
    puts "Seeding database..."
    Rake::Task["db:seed"].invoke
  end

  task scrub: :environment do
    ENV['RAILS_ENV'] ||= Rails.env

    throw "You're trying to reset db in production!!!" if ENV['RAILS_ENV'] == 'production'

    puts "Scrubbing database..."
    Subscriber.all.each.with_index do |s,i|
      s.update_columns email: "scrubbed.subscriber+#{i}@***.com", auth_token: "*****#{i}****"
    end
    DonorCard.all.each.with_index do |dc,i|
      dc.update_columns email: "scrubbed.donorcard+#{i}@***.com"
    end
    Gift.all.each.with_index do |g,i|
      g.update_columns giver_email: g.giver_subscriber.email, recipient_email: g.donor.card.email
    end
    Email.update_all to: "***@***.com"
    User.update_all reset_password_token: nil
    Audited::Adapters::ActiveRecord::Audit.delete_all
  end
end
