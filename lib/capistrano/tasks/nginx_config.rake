require 'active_support'
require 'active_support/core_ext/string/filters'
require 'capistrano/helpers/puma/template_paths'
require 'capistrano/helpers/base'
include Capistrano::Helpers::Base
include Capistrano::Helpers::Puma

namespace :load do
  task :defaults do
    # Where your nginx lives. Usually /opt/nginx or /usr/local/nginx for source compiled.
    set :nginx_sites_enabled_path, '/etc/nginx/sites-enabled'

    # simple authorization in nginx recipe
    # Remember NOT to share your deployment file in case you have sensitive passwords stored in it...
    # This is added to make it easier to deploy staging sites with a simple htpasswd.

    set :nginx_use_simple_auth, false
    set :nginx_simple_auth_message, 'Restricted site'
    set :nginx_simple_auth_user, 'user'
    set :nginx_simple_auth_password, nil # if set to nil, it will automatically be generated
    set :nginx_simple_auth_salt, (0...8).map { ('a'..'z').to_a[rand(26)] }.join

    # Server names. Defaults to application name.
    set :server_names, proc { app_env_underscore }

    # Path to the nginx erb template to be parsed before uploading to remote
    set :nginx_config_template, File.join(TemplatePaths.template_base_path, 'nginx', 'application.conf.erb') # rubocop:disable Metrics/LineLength

    # Path to where your remote config will reside (I use a directory sites inside conf)
    set :nginx_remote_config, proc { shared_path.join('config', "nginx_#{app_env_underscore}.conf") }

    # Path to local htpasswd template file
    set :nginx_htpasswd_template, File.join(TemplatePaths.template_base_path, 'nginx', 'htpasswd.erb')

    # Path to remote htpasswd file
    set :nginx_remote_htpasswd, proc { shared_path.join('config', '.htpasswd') }

    set :nginx_sites_enabled_symlink, proc { File.join(fetch(:nginx_sites_enabled_path), app_env_underscore) }

    set :nginx_uses_http, true
    set :nginx_uses_ssl, false
    set :nginx_port, 80

    set :nginx_log_path, proc { File.join('/var', 'log', 'nginx') }

    set :nginx_app_log_path, proc { File.join(fetch(:nginx_log_path), fetch(:application).squish.downcase.gsub(/[\s|-]/, '_')) }

    set :nginx_client_max_body_size, '10M'

    set :nginx_ssl_port, 443
    set :nginx_ssl_use_simple_auth, false
    set :nginx_ssl_client_max_body_size, '10M'
    set :nginx_ssl_public_crt, File.join('/etc', 'certs', 'server.crt')
    set :nginx_ssl_private_key, File.join('/etc', 'certs', 'server.key')
  end
end
