require 'capistrano/helpers/base'
require 'capistrano/helpers/monit'
require 'capistrano/helpers/puma/monit'
require 'capistrano/dsl/base_paths'
include Capistrano::DSL::BasePaths
include Capistrano::Helpers::Base
include Capistrano::Helpers::Monit
include Capistrano::Helpers::Puma::Monit

namespace :puma do
  namespace :monit do
    desc 'MONIT: Setup Puma service'
    task :setup do
      on roles(:app) do |host|
        info "MONIT: Uploading configuration for puma for #{fetch(:application)} on #{host}"
        # Upload configuration
        upload! template_to_s_io(fetch(:puma_monit_config_template)), available_configuration_with_path
      end
    end

    desc 'MONIT: Enable services for Puma'
    task :enable do
      on roles(:app) do |host|
        info "MONIT: Enabling service for puma for application #{fetch(:application)} on #{host}"
        enable_monitor(available_configuration_file )
      end
    end

    desc 'MONIT: Disable and Stop services for  Puma'
    task :disable do
      on roles(:app) do |host|
        info "MONIT: Disabling service for puma for application #{fetch(:application)} on #{host}"
        disable_monitor(available_configuration_file)
      end
    end

    %w(start stop restart monitor unmonitor).each do |cmd|
      desc "MONIT: #{cmd.capitalize} puma"
      task cmd.to_sym do
        on roles(:app) do |host|
          info "MONIT: #{cmd} #{fetch(:puma_monit_service_name)} on #{host}"
          command_monit(cmd, fetch(:puma_monit_service_name))
        end
      end
    end

    desc 'MONIT: Purge Puma configuration'
    task :purge do
      on roles(:app) do |host|
        info "MONIT: Purging config for #{fetch(:puma_monit_service_name)} on #{host}"
      end
    end
  end
end

after 'monit:setup', 'puma:monit:setup'
# after 'puma:monit:setup', 'puma:monit:enable'
after 'puma:monit:enable', 'monit:reload'

before 'puma:monit:disable', 'puma:monit:unmonitor'
after 'puma:monit:disable', 'monit:reload'

# start service after update in case it has not been stopped
# This shouldn't be necessary, as monit should pick up a non-running service.
# Starting it here might trigger double starting if monit is triggered simultaniously.
# after "deploy:update", "puma:monit:start"
