set :application, "plt"
set :repository,  "https://northpoint.devguard.com/svn/plt/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/deploy/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

set :user, "deploy"
set :password, "NorthPoint99"
set :use_sudo, false
#set :port, 7785
set :port, 22

set :svn_username, "deploy"
set :svn_password, "NorthPoint99"

role :app, "174.143.205.24"
role :web, "174.143.205.24"
role :db,  "174.143.205.24", :primary => true

set :keep_releases, 3

set :rails_env, "production"

namespace :deploy do
  task :reset_database do
    run "cd #{deploy_to}/current && RAILS_ENV=production rake db:migrate VERSION=0"
  end

  task :seed do
    run "cd #{deploy_to}/current && RAILS_ENV=production rake db:seed"
  end

  task :populate do
    run "cd #{deploy_to}/current && RAILS_ENV=production rake db:populate"
  end

  task :import_customers do
    run "cd #{deploy_to}/current && RAILS_ENV=production rake db:import_customers_and_loans"
  end

  task :import_payments do
    run "cd #{deploy_to}/current && RAILS_ENV=production rake db:import_payments"
  end

  task :set_demo_loan_states do
    run "cd #{deploy_to}/current && RAILS_ENV=production rake db:set_demo_loan_states"
  end

  task :set_demo_funded_loans do
    run "cd #{deploy_to}/current && RAILS_ENV=production rake db:loan_funded"
  end

  task :test_email do
    run "cd #{deploy_to}/current && RAILS_ENV=production rake email:send_test_email"
  end

  task :migrate do
    run "cd #{deploy_to}/current && RAILS_ENV=production rake db:migrate"
  end

  task :restart do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end

  task :rebuild_sphinx_index do
    run "cd #{deploy_to}/current && RAILS_ENV=production rake thinking_sphinx:rebuild"
  end

  desc "Re-establish symlink for Sphinx to shared location"
  task :after_symlink do
    run <<-CMD
      rm -fr #{release_path}/db/sphinx &&
      ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx
    CMD
  end
end

#before "deploy:update_code", "deploy:stop_daemons"
after "deploy:update", "deploy:cleanup"