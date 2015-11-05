namespace :db do
  desc "Backup the database"
  task :backup do
    on roles(:jobs) do |host|
      backup_path = "#{fetch(:deploy_to)}/backups"
      execute :mkdir, "-p #{backup_path}"
      basename = 'database'

      username, password, database, host = config_for_database(fetch(:stage))

      filename = "#{basename}_#{fetch(:stage)}_#{database}_#{Time.now.strftime '%Y-%m-%d_%H:%M:%S'}.sql.bz2"
      set :backup_path, "#{backup_path}/#{filename}"
      debug "Backing up to '#{fetch(:backup_path)}'"

      with_no_output do
        execute :mysqldump, "-u #{username} --password='#{password}' --databases #{database} #{'-h ' + host unless host.nil?} | bzip2 -9 > #{fetch(:backup_path)}"
      end
    end
  end

  desc "Backup, scrub, and import from jobs-role server"
  task :import do
    on roles(:jobs) do |host|
      invoke("db:backup")

      puts "Fetching #{fetch(:rails_env)} snapshot..."
      download! fetch(:backup_path), "/tmp/#{fetch(:application)}.sql.bz2"
      c = YAML.load_file("config/database.yml")["development"]
      run_str = "bzcat /tmp/#{fetch(:application)}.sql.bz2 | mysql -u #{c['user'] || c['username']} --password='#{c['password']}' #{'-h ' + c['host'] unless c['host'].nil? || c['host'] == ''} #{c['database']}"

      puts "Dropping local database in 5 seconds..."
      (1..5).each { |i| puts "#{i}... "; sleep 1 }
      system("bundle exec rake db:drop")
      system("bundle exec rake db:create")

      puts "Importing #{fetch(:rails_env)} snapshot..."
      puts run_str
      system(run_str)

      system "bundle exec rake db:scrub"
      system "rm /tmp/#{fetch(:application)}.sql.bz2"
      puts "Finished!"
    end
  end

  def with_no_output(&blk)
    SSHKit.config.output_verbosity = Logger::FATAL
    result = yield
    SSHKit.config.output_verbosity = Logger::DEBUG
    result
  end

  def config_for_database(db)
    remote_config = with_no_output { capture("cat #{shared_path}/config/database.yml") }

    database = YAML::load(remote_config)
    return database["#{db}"]['username'], database["#{db}"]['password'], database["#{db}"]['database'], database["#{db}"]['host']
  end
end
