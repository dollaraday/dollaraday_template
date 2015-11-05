# config valid only for Capistrano 3.4
lock '3.4.0'

set :application, 'my_app_name'
set :repo_url, 'git@github.com:my_github_username/my_github_repo.git'
set :branch, 'master'
set :keep_releases, 5
# set :rbenv_ruby, '2.1.2'
set :delayed_job_server_role, :jobs # Re: https://github.com/collectiveidea/delayed_job/wiki/Delayed-Job-tasks-for-Capistrano-3
set :delayed_job_args, "-n 1"

# NB: we need to include :jobs in here so DJ can use assets in emails
set :assets_roles, [:web, :app, :jobs]

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, "/apps/my_app_name"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Don't regenerate binstubs from bundler
set :bundle_binstubs, nil

set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/assets}
set :linked_files, %w{
  config/config.yml
  config/database.yml
  config/s3.yml
  config/secrets.yml
  config/stripe.yml
  config/mail.yml
  config/mailgun.yml
  config/nfg.yml
  config/devise.yml
}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :logs do
  desc "tail rails logs"
  task :tail_rails do
    on roles(:app) do
      execute "tail -f #{shared_path}/log/#{fetch(:rails_env)}.log"
    end
  end
end

namespace :deploy do
  desc "Initial setup"
  task :setup do
    on roles(:all) do
      execute "mkdir -p #{shared_path}/config"
      execute "mkdir -p #{shared_path}/tmp/cache"
      execute "mkdir -p #{shared_path}/tmp/sockets"

      # TODO fix,so we don't accidentally overwrite the config files
      raise "config.yml already exists!" if test("[ -t #{shared_path}/config/config.yml]")

      upload! "config/config.yml.example", "#{shared_path}/config/config.yml"
      upload! "config/database.yml.example", "#{shared_path}/config/database.yml"
      upload! "config/secrets.yml.example", "#{shared_path}/config/secrets.yml"
      upload! "config/s3.yml.example", "#{shared_path}/config/s3.yml"
      upload! "config/stripe.yml.example", "#{shared_path}/config/stripe.yml"
      upload! "config/mail.yml.example", "#{shared_path}/config/mail.yml"
      upload! "config/mailgun.yml.example", "#{shared_path}/config/mailgun.yml"
      upload! "config/nfg.yml.example", "#{shared_path}/config/nfg.yml"
      upload! "config/devise.yml.example", "#{shared_path}/config/devise.yml"
      info "\n\n\n\n\n\n\n\n*********************"
      info "NOTICE: Now edit the config files in #{shared_path}."
      info "\n\n\n\n\n\n\n\n*********************"
    end
  end


  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:all) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        info "WARNING: HEAD is not the same as origin/master"
        info "Run `git push` to sync changes."
        exit
      end
    end
  end

  before "deploy", "deploy:check_revision"

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :groups, limit: 2, wait: 5 do
      execute "/etc/init.d/unicorn_rails restart"
    end
    on roles(:jobs), in: :parallel do
      invoke 'delayed_job:restart'
    end
  end
  after :publishing, :restart

  namespace :nginx do
    desc 'Restart web (nginx)'
    task :restart do
      on roles(:web), in: :parallel do
        execute "sudo nginx -s reload"
      end
    end
  end
end
