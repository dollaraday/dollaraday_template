namespace :intercom do

  desc 'Sync all user data to intercom'
  task :sync => :environment do

    Subscriber.all.each(&:update_intercom)

  end

end
