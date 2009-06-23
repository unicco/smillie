set :application, "smillie"
set :repository,  "http://smillie.jp/svn/smillie/trunk"
set :deploy_to, "/home/smillie/app"
set :svn_username, "tinymonks"
set :user, "smillie"
set :use_sudo, false
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
set :config_dir, "/home/smillie/config"

role :app, "smillie.jp"
role :web, "smillie.jp"
role :db,  "smillie.jp", :primary => true

after "deploy:finalize_update" do
  run "cp -f #{config_dir}/database.yml #{release_path}/config/"
  run "ln -nfs #{shared_path}/photos #{release_path}/public/photos"
  run "ln -nfs #{shared_path}/qrcodes #{release_path}/public/qrcodes"
end

namespace :deploy do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "mongrel_rails cluster::restart -C #{mongrel_conf}"
  end
  
  task :start, :roles => :app do
    run "mongrel_rails cluster::start -C #{mongrel_conf}"
  end
  
  task :stop, :roles => :app do
    run "mongrel_rails cluster::stop -C #{mongrel_conf}"
  end
end
