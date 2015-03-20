require 'capistrano/dsl/base_paths'
require 'capistrano/helpers/base'
require 'capistrano/helpers/puma/nginx'
include Capistrano::DSL::BasePaths
include Capistrano::Helpers::Base
include Capistrano::Helpers::Puma::Nginx

namespace :puma do
  namespace :nginx do
    desc 'Get the config needed to add to sudoers for nginx commands'
    task :sudoers do
      run_locally do
        info '---------------ENTRIES FOR SUDOERS (Nginx)---------------------'
        puts '#---------------ENTRIES FOR SUDOERS (Nginx)---------------------'
        puts "#{fetch(:user)} ALL=NOPASSWD: /bin/mkdir -p #{fetch(:nginx_log_path)}"
        puts "#{fetch(:user)} ALL=NOPASSWD: /bin/chown -R #{fetch(:user)}\\:root #{fetch(:nginx_log_path)}"
        puts "#{fetch(:user)} ALL=NOPASSWD: /bin/chmod 6775 #{fetch(:nginx_log_path)}"
        puts "#{fetch(:user)} ALL=NOPASSWD: /usr/sbin/service nginx *"
        puts '#---------------------------------------------------------------'
        info '---------------------------------------------------------------'
      end
      # info "#{fetch(:user)} ALL=NOPASSWD: /bin/chown deploy:root #{monit_monitrc_file}"
    end

    desc 'Generates and uploads nginx configuration for this app to the App server(s)'
    # task :setup, :roles => :app , :except => { :no_release => true } do
    task :setup do
      # Will setup nginx on the application server, as single-host app/web server is used behind load balancer
      # Nginx is used for talking over socket to puma instead of opening puma to the 'world'
      on roles(:app) do |host|
        info "NGINX: Setting up for puma for #{fetch(:application)} on #{host}"
        upload! template_to_s_io(fetch(:nginx_config_template)), fetch(:nginx_remote_config)
        if (fetch(:nginx_use_simple_auth)) || fetch(:nginx_ssl_use_simple_auth)
          set :pw, ask('', '')
          set :create_httpwd, ask('Create .httpasswd configuration file [Yn]', 'Y')
          # if auth is enabled, upload htpasswd file
          # Since passwords are stored in plaintext in the deployment file, you should use simple auth with care.
          # It is generally better to implement a full authorization stack like oauth, use devise on rails,
          # or other login/auth system
          if fetch(:create_httpwd)
            set :nginx_simple_auth_password, default_pw_generator if fetch(:nginx_simple_auth_password).nil?
            upload! template_to_s_io(fetch(:nginx_htpasswd_template)), fetch(:nginx_remote_htpasswd)
          else
            set :nginx_use_simple_auth, false
            set :nginx_ssl_use_simple_auth, false
          end
        end
        # create log path
        # /var/log/nginx must be writable by 'deploy' user, usually this can be acomplished by adding the deploy user to
        # the www-data group
        execute :sudo, :mkdir, "-p #{fetch(:nginx_log_path)}"
        execute :sudo, :chown, "-R #{fetch(:user)}:root #{fetch(:nginx_log_path)}"
        execute :sudo, :chmod, "6775 #{fetch(:nginx_log_path)}"
        execute :mkdir, "-p #{fetch(:nginx_app_log_path)}"
      end
    end

    desc 'Enable nginx site for the application'
    task :enable do
      on roles(:app) do |host|
        if test("[ ! -h #{fetch(:nginx_sites_enabled_symlink)} ]")
          info "NGINX: Enabling application #{fetch(:application)} on #{host}"
          execute :ln, "-sf #{fetch(:nginx_remote_config)} #{fetch(:nginx_sites_enabled_symlink)}"
        else
          info "NGINX: Already enabled application #{fetch(:application)} on #{host}"
        end
      end
    end

    desc 'Disable nginx site for the application'
    task :disable do
      on roles(:app) do |host|
        if test("[ -h #{fetch(:nginx_sites_enabled_symlink)} ]")
          info "NGINX: Disabling application #{fetch(:application)} on #{host}"
          execute :rm, "-f #{fetch(:nginx_sites_enabled_symlink)}"
        else
          info "NGINX: Already disabled application #{fetch(:application)} on #{host}"
        end
      end
    end

    desc 'Purge nginx site config for the application'
    task :purge do
      on roles(:app) do |host|
        info "NGINX: Purging configuration for #{fetch(:application)} on #{host}"
        execute :rm, "-f #{fetch(:nginx_sites_enabled_symlink)}" if test("[ -h #{fetch(:nginx_sites_enabled_symlink)} ]")
        execute :rm, "-f #{fetch(:nginx_remote_htpasswd)}"
        execute :rm, "-f #{fetch(:nginx_remote_config)}"
        # must restart nginx to make sure site is disabled when config is purge
        execute :sudo, :service, 'nginx restart'
      end
    end
  end
end

namespace :nginx do
  %w(start stop restart status).each do |nginx_cmd|
    desc "Nginx/Puma: #{nginx_cmd.capitalize}"
    task nginx_cmd.to_sym do
      on roles(:app) do |host|
        info "NGINX: Performing #{nginx_cmd} for #{fetch(:application)} on #{host}"
        execute :sudo, :service, "nginx #{nginx_cmd}"
      end
    end
  end
end

# after 'deploy:setup' do
#   puma.nginx.setup if Capistrano::CLI.ui.agree("Create nginx configuration file? [Yn]")
#   if Capistrano::CLI.ui.agree("Enable site in nginx? [Yn]")
#     puma.nginx.enable
#     nginx.restart # must restart after enable for nginx to pickup new site
#   end
# end
