set :default_stage, "n2_staging"
set :stages, %w(n2_production n2_staging chewbranca_staging)
require 'capistrano/ext/multistage'

default_run_options[:pty] = true

set :repository,  "git://github.com/newscloud/n2.git"
set :scm, :git
set :deploy_via, :remote_cache

set (:deploy_to) { "/data/sites/#{application}" }

set :user, 'deploy'
set :use_sudo, false

task :after_update_code do
  # setup shared files
  %w{/config/unicorn.conf.rb /tmp/sockets /config/database.yml
    /config/facebooker.yml /config/application_settings.yml
    /config/application.god /config/newrelic.yml
    /config/smtp.yml}.each do |file|
      run "ln -nfs #{shared_path}#{file} #{release_path}#{file}"
  end

  deploy.cleanup
end

task :before_deploy do
  deploy.god.stop
end

task :after_deploy do
  deploy.god.start
end

task :after_deploy do
  #deploy.notify_hoptoad
  newrelic.notice_deployment
end

task :after_setup do
  if stage.to_s[0,3] == "n2_"
  	puts "Setting up default config files"
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/tmp/sockets"
    run "cp /data/defaults/config/* #{shared_path}/config/"
  end
end

namespace :deploy do
  
  namespace :god do
    desc "Stop God monitoring"
    task :stop, :roles => :app, :on_error => :continue do
      run 'god quit'
    end

    desc "Start God monitoring"
    task :start, :roles => :app do
      run "god -c #{current_path}/config/application.god"
    end
  end

  desc "Restart application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "cat #{current_path}/tmp/pids/unicorn.pid | xargs kill -USR2"
  end

  desc "Start application"
  task :start, :roles => :app do
    run "cd #{current_path} && /usr/bin/unicorn_rails -c #{current_path}/config/unicorn.conf.rb -E #{rails_env} -D"
  end

  desc "Stop application"
  task :stop, :roles => :app do
    run "cat #{current_path}/tmp/pids/unicorn.pid | xargs kill -QUIT"
  end
end
