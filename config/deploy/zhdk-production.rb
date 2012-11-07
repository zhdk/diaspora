#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
require "rvm/capistrano"
set :rvm_ruby_string, '1.9.2'        # Or whatever env you want it to run in.
set :rvm_type, :system

require 'bundler/capistrano'
require './config/boot'

require 'capistrano/ext/multistage'

set :repository, "git://github.com/zhdk/diaspora.git"
set :application, 'diaspora'
set :scm, :git
set :branch, "develop"
set :use_sudo, false
set :scm_verbose, true
set :checkout, :export

set :bundle_without,  [:development, :test, :heroku]
set :deploy_to, "/home/diaspora/diaspora"

role :app, "diaspora@rails.zhdk.ch"
role :web, "diaspora@rails.zhdk.ch"
role :db,  "diaspora@rails.zhdk.ch", :primary => true

namespace :deploy do
  task :symlink_config_files do
    run "ln -s -f #{shared_path}/config/database.yml #{current_path}/config/database.yml"
    run "ln -s -f #{shared_path}/config/diaspora.yml #{current_path}/config/diaspora.yml"
  end

  task :symlink_cookie_secret do
    run "ln -s -f #{shared_path}/config/initializers/secret_token.rb #{current_path}/config/initializers/secret_token.rb"
  end

  task :bundle_static_assets do
    run "cd #{current_path} && bundle exec rake assets:precompile"
  end

  task :restart do
    run "touch #{latest_release}/tmp/restart.txt"
  end

  desc 'Copy resque-web assets to public folder'
  task :copy_resque_assets do
    target = "#{release_path}/public/resque-jobs"
    run "cp -r `cd #{release_path} && bundle show resque`/lib/resque/server/public #{target}"
  end

  desc 'Start a resque worker'
  task :start_resque_worker do
    run "cd #{release_path} && RAILS_ENV=production QUEUE=* bundle exec rake resque:work"
  end

end

after 'deploy:create_symlink' do
  deploy.symlink_config_files
  deploy.symlink_cookie_secret
  deploy.bundle_static_assets
  deploy.copy_resque_assets
  deploy.start_resque_worker
end


