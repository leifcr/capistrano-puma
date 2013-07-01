# Puma - Monit
# Setup and management of Monit for Puma
#
require 'base_helper'

Capistrano::Configuration.instance(true).load do
  after "deploy:setup", "puma:monit:setup"
  after "puma:monit:setup", "puma:monit:enable"
  after "puma:monit:enable", "monit:reload"
  after "puma:monit:enable", "puma:monit:monitor" 
  after "puma:monit:disable", "monit:reload"
  before "puma:monit.disable", "puma:monit:unmonitor"

  # start service after update in case it has not been stopped
  # after "deploy:update", "puma:monit:start"
  # Not needed?

  namespace :puma do
    namespace :monit do
      desc "Setup Puma monit-service"
      task :setup, :roles => [:app, :web, :db] do
        # Upload configuration
        Capistrano::BaseHelper::generate_and_upload_config(puma_local_monit_config, File.join(fetch(:monit_available_path), "#{fetch(:puma_runit_service_name)}.conf"))
        # Enable monitor
      end
    
      desc "Enable monit services for puma"
      task :enable, :roles => [:app, :web, :db] do
        Capistrano::MonitBase::Service.enable("#{fetch(:puma_runit_service_name)}.conf")
      end

      desc "Disable and stop monit services for puma"
      task :disable, :roles => [:app, :web, :db] do
        Capistrano::MonitBase::Service.disable("#{fetch(:puma_runit_service_name)}.conf")
      end

      desc "Start monit services for puma (will also try to start the service)"
      task :start, :roles => [:app, :web, :db] do
        Capistrano::MonitBase::Service.command_monit("start", fetch(:puma_monit_service_name))
      end

      desc "Stop monit services for puma (will also stop the service)"
      task :stop, :roles => [:app, :web, :db] do
        Capistrano::MonitBase::Service.command_monit("stop", fetch(:puma_monit_service_name))
      end

      desc "Restart monit services for puma"
      task :restart, :roles => [:app, :web, :db] do
        Capistrano::MonitBase::Service.command_monit("restart", fetch(:puma_monit_service_name))
      end

      desc "Monitor puma"
      task :monitor, :roles => [:app, :web, :db] do
        Capistrano::MonitBase::Service.command_monit("monitor", fetch(:puma_monit_service_name))
      end

      desc "Unmonitor puma"
      task :unmonitor, :roles => [:app, :web, :db] do
        Capistrano::MonitBase::Service.command_monit("unmonitor", fetch(:puma_monit_service_name))
      end

      desc "Purge puma monit configuration"
      task :unmonitor, :roles => [:app, :web, :db], :on_error => :continue do
      end      

    end

  end
end