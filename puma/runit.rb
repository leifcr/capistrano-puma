# Puma - Runit

require 'base_helper'

Capistrano::Configuration.instance(true).load do
  after "deploy:setup", "puma:runit:setup"

  # enable service after update in case it has not been setup or is disabled
  # Service should probably be started as well?
  after "deploy:update", "puma:runit:enable"
  before "puma:runit:setup", "puma:runit:flush_sockets"
  after "puma:runit:quit", "puma:runit:stop"

  namespace :puma do
    namespace :runit do
      desc "Setup Puma runit-service"
      task :setup, :roles => :app do
        Capistrano::BaseHelper.prepare_path(File.join(fetch(:shared_path), "sockets"), fetch(:user), fetch(:group))

        # Create puma configuration file
        Capistrano::BaseHelper::generate_and_upload_config(fetch(:puma_local_config), fetch(:puma_remote_config))

        # Create runit config
        Capistrano::RunitBase.create_service_dir(puma_runit_service_name)
        Capistrano::BaseHelper::generate_and_upload_config(puma_runit_local_config, Capistrano::RunitBase.remote_run_config_path(puma_runit_service_name))
        #must use quit script for stop as well
        Capistrano::BaseHelper::generate_and_upload_config(puma_runit_control_q, Capistrano::RunitBase.remote_control_path(puma_runit_service_name, "q"))
        Capistrano::BaseHelper::generate_and_upload_config(puma_runit_control_q, Capistrano::RunitBase.remote_control_path(puma_runit_service_name, "s"))
        Capistrano::BaseHelper::generate_and_upload_config(puma_runit_local_log_run, Capistrano::RunitBase.remote_service_log_run_path(puma_runit_service_name))

        # Make scripts executable
        Capistrano::RunitBase.make_service_scripts_executeable(puma_runit_service_name)
        # Set correct permissions/owner on log path
        Capistrano::RunitBase.create_and_permissions_on_path(fetch(:puma_log_path))
      end 
      
      desc "Enable Puma runit-service"
      task :enable, :roles => :app do
        Capistrano::RunitBase.enable_service(puma_runit_service_name)
      end

      desc "Disable Puma runit-service"
      task :disable, :roles => :app do
        Capistrano::RunitBase.disable_service(puma_runit_service_name)
      end

      desc "Start Puma runit-service"
      task :start, :roles => :app do
        Capistrano::RunitBase.start_service(puma_runit_service_name)
      end

      desc "Start Puma runit-service only ONCE (no supervision...)"
      task :once, :roles => :app do
        Capistrano::RunitBase.start_service_once(puma_runit_service_name)
      end

      desc "Stop Puma runit-service"
      task :stop, :roles => :app, :on_error => :continue do
        # have to use force-stop on failed stop, since puma might not terminate properly
        # will wait 25 seconds for puma to shut down, to allow it to serve any on-going requests
        Capistrano::RunitBase.control_service(puma_runit_service_name, "force-stop", false, "-w 25")
      end

      desc "Quit the puma runit-service"
      task :quit, :roles => :app, :on_error => :continue do
        Capistrano::RunitBase.control_service(puma_runit_service_name, "quit")
      end

      desc "Restart Puma runit-service"
      task :restart, :roles => :app do
        # Send USR2 to puma in order to restart it....
        Capistrano::RunitBase.control_service(puma_runit_service_name, "2")
      end
      
      desc "Flush puma sockets, as they can end up 'hanging around'"
      task :flush_sockets, :roles => :app do
        run "rm -f #{fetch(:puma_socket_file)}; rm -f #{fetch(:puma_control_file)}"
      end

      desc "Purge puma runit configuration"
      task :purge, :roles => :app, :on_error => :continue do
        Capistrano::RunitBase.force_control_service(puma_runit_service_name, "force-stop", true)
        Capistrano::RunitBase.purge_service(puma_runit_service_name)
      end
      
    end
  end
end