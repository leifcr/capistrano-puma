require 'capistrano/puma/config'
require 'capistrano/base_helper/monit_base'

Capistrano::Configuration.instance.load do

  # Where your nginx lives. Usually /opt/nginx or /usr/local/nginx for source compiled.
  _cset :nginx_sites_enabled_path, "/etc/nginx/sites-enabled"

  # simple authorization in nginx recipe
  # Remember NOT to share your deployment file in case you have sensitive passwords stored in it...
  # This is added to make it easier to deploy staging sites with a simple htpasswd.

  _cset :nginx_use_simple_auth, false
  _cset :nginx_simple_auth_message, "Restricted site"
  _cset :nginx_simple_auth_user, "user"
  _cset :nginx_simple_auth_password, "password"
  _cset :nginx_simple_auth_salt, (0...8).map{ ('a'..'z').to_a[rand(26)] }.join

  # Server names. Defaults to application name.
  _cset :server_names, defer {"#{application}_#{Capistrano::BaseHelper.environment}"}

  # Path to the nginx erb template to be parsed before uploading to remote
  _cset :nginx_local_config, File.join(File.expand_path(File.join(File.dirname(__FILE__),"../../../templates", "nginx", )), "application.conf.erb")

  # Path to where your remote config will reside (I use a directory sites inside conf)
  _cset :nginx_remote_config, defer {File.join("#{fetch(:shared_path)}", "config", "nginx_#{fetch(:application)}_#{Capistrano::BaseHelper.environment}.conf")}

  # Path to local htpasswd template file
  _cset :nginx_local_htpasswd, defer {File.join(File.expand_path(File.join(File.dirname(__FILE__),"../../../templates", "nginx", )), "htpasswd.erb")}

  # Path to remote htpasswd file
  _cset :nginx_remote_htpasswd, defer {File.join("#{fetch(:shared_path)}", "config", ".htpasswd")}

  _cset :nginx_sites_enabled_symlink, defer {File.join(nginx_sites_enabled_path, "#{fetch(:application)}_#{Capistrano::BaseHelper.environment}")}

  _cset :nginx_uses_http, true
  _cset :nginx_uses_ssl, false
  _cset :nginx_port, 80

  _cset :nginx_log_path, File.join("/var", "log", "nginx", "#{fetch(:application)}")

  _cset :nginx_client_max_body_size, "10M"

  _cset :nginx_ssl_port, 443
  _cset :nginx_ssl_use_simple_auth, false
  _cset :nginx_ssl_client_max_body_size, "10M"
  _cset :nginx_ssl_public_crt, File.join("/etc", "certs", "server.crt")
  _cset :nginx_ssl_private_key, File.join("/etc", "certs", "server.key")

  # Nginx tasks are not *nix agnostic, they assume you're using Debian/Ubuntu.
  # Override them as needed.
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

end
