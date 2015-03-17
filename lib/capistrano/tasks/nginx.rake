namespace :puma do
  namespace :nginx do
    desc "Parses and uploads nginx configuration for this app."
    task :setup, :roles => :app , :except => { :no_release => true } do

      Capistrano::BaseHelper.generate_and_upload_config(fetch(:nginx_local_config), fetch(:nginx_remote_config))

      # if auth is enabled, upload htpasswd file
      # Since passwords are stored in plaintext in the deployment file, you should use simple auth with care.
      # It is generally better to implement a full authorization stack like oauth, use devise on rails, or other login/auth system
      if fetch(:nginx_use_simple_auth) or fetch(:nginx_ssl_use_simple_auth)
        if Capistrano::CLI.ui.agree("Create .htpasswd configuration file? [Yn]")
          Capistrano::BaseHelper.generate_and_upload_config(fetch(:nginx_local_htpasswd), fetch(:nginx_remote_htpasswd))
        else
          set :nginx_use_simple_auth, false
          set :nginx_ssl_use_simple_auth, false
        end
      end

      # create log path, must sudo since path can have root-only permissions
      run "#{sudo} mkdir -p /var/log/nginx/#{fetch(:application)} && #{sudo} chown root:www-data /var/log/nginx/#{fetch(:application)}"
    end

    desc "Enable nginx site for the application"
    task :enable, :roles => :app , :except => { :no_release => true } do
      # symlink to nginx site configuration file
      run("[ -h #{fetch(:nginx_sites_enabled_symlink)} ] || #{sudo} ln -sf #{fetch(:nginx_remote_config)} #{fetch(:nginx_sites_enabled_symlink)}")
    end

    desc "Disable nginx site for the application"
    task :disable, :roles => :app , :except => { :no_release => true } do
      run("[ ! -h #{fetch(:nginx_sites_enabled_symlink)} ] || #{sudo} rm -f #{fetch(:nginx_sites_enabled_symlink)}")
    end

    desc "Purge nginx site config for the application"
    task :purge, :roles => :app , :except => { :no_release => true } do
      run("[ ! -h #{fetch(:nginx_sites_enabled_symlink)} ] || #{sudo} rm -f #{fetch(:nginx_sites_enabled_symlink)}")
      # must restart nginx to make sure site is disabled when config is purge
      run "#{sudo} service nginx restart"
      run "rm -f #{fetch(:nginx_remote_htpasswd)} && rm -f #{fetch(:nginx_remote_config)}"
    end

  end
end

namespace :nginx do
  desc "Restart nginx"
  task :restart, :roles => :app , :except => { :no_release => true } do
    run "#{sudo} service nginx restart"
  end

  desc "Stop nginx"
  task :stop, :roles => :app , :except => { :no_release => true } do
    run "#{sudo} service nginx stop"
  end

  desc "Start nginx"
  task :start, :roles => :app , :except => { :no_release => true } do
    run "#{sudo} service nginx start"
  end

  desc "Show nginx status"
  task :status, :roles => :app , :except => { :no_release => true } do
    run "#{sudo} service nginx status"
  end

end

after 'deploy:setup' do
  puma.nginx.setup if Capistrano::CLI.ui.agree("Create nginx configuration file? [Yn]")
  if Capistrano::CLI.ui.agree("Enable site in nginx? [Yn]")
    puma.nginx.enable
    nginx.restart # must restart after enable for nginx to pickup new site
  end
end
