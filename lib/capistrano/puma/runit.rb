# Puma - Runit
require 'capistrano/puma/config'
require 'capistrano/base_helper/runit_base'

Capistrano::Configuration.instance(true).load do
  after "deploy:setup", "puma:runit:setup"

  # enable service after update in case it has not been setup or is disabled
  # Service should probably be started as well?
  after "deploy:update", "puma:runit:enable"
  before "puma:runit:setup", "puma:flush_sockets"
  before "puma:runit:setup", "puma:setup"
  before "puma:runit:quit", "puma:runit:stop"

  namespace :puma do

    desc "Setup Puma configuration"
    task :setup, :roles => :app do
      Capistrano::BaseHelper.prepare_path(File.join(fetch(:shared_path), "sockets"), fetch(:user), fetch(:group))

      # Create puma configuration file
      Capistrano::BaseHelper::generate_and_upload_config(fetch(:puma_local_config), fetch(:puma_remote_config))
    end

    desc "Flush Puma sockets, as they can end up 'hanging around'"
    task :flush_sockets, :roles => :app do
      run "rm -f #{fetch(:puma_socket_file)}; rm -f #{fetch(:puma_control_file)}"
    end

    namespace :runit do
      desc "Setup Puma runit-service"
      task :setup, :roles => :app do


        # Create runit config
        Capistrano::RunitBase.create_service_dir(puma_runit_service_name)
        Capistrano::BaseHelper::generate_and_upload_config(puma_runit_local_run, Capistrano::RunitBase.remote_run_config_path(puma_runit_service_name))
        Capistrano::BaseHelper::generate_and_upload_config(puma_runit_local_finish, Capistrano::RunitBase.remote_finish_config_path(puma_runit_service_name))

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
        result     = nil
        started    = false

        # It is not possible to see if a restart is in progress using the pumactl tool as of now.

        # restarting = false
        # # check if puma is already performing a restart
        # invoke_command("cd #{fetch(:current_path)}; [[ $(#{fetch(:puma_control)} -S #{fetch(:puma_state_file)} status) == *restart* ]] && echo 'restarting';true") do |ch, stream, out|
        #   result = (/restart/ =~ out)
        # end
        # restarting = true unless result.nil?
        # result     = nil

        # if restarting == false
          # check if it is running
          invoke_command("cd #{fetch(:current_path)}; [[ $(#{fetch(:puma_control)} -S #{fetch(:puma_state_file)} status) == *started* ]] && echo 'started';true") do |ch, stream, out|
            result = (/started/ =~ out)
          end
          started = true unless result.nil?

          if started == true
            logger.info("\nRestarting puma")
            # Send USR2 to puma in order to restart it....
            Capistrano::RunitBase.control_service(puma_runit_service_name, "2")
          else
            logger.important("\nStarting puma, (wasn't running before)")
            Capistrano::RunitBase.start_service(puma_runit_service_name)
          end
        # end
      end

      desc "Phased Restart of Puma"
      task :phased_restart, :roles => :app do
        result     = nil
        started    = false

        # check if it is running
        invoke_command("cd #{fetch(:current_path)}; [[ $(#{fetch(:puma_control)} -S #{fetch(:puma_state_file)} status) == *started* ]] && echo 'started';true") do |ch, stream, out|
          result = (/started/ =~ out)
        end
        started = true unless result.nil?

        if started == true
          # Send USR1 to puma in order to restart it....
          logger.info("\nPhased restart of puma")
          Capistrano::RunitBase.control_service(puma_runit_service_name, "1")
        else
          logger.important("\nStarting puma, (wasn't running before)")
          Capistrano::RunitBase.start_service(puma_runit_service_name)
        end
      end

      desc "Purge Puma runit configuration"
      task :purge, :roles => :app, :on_error => :continue do
        Capistrano::RunitBase.force_control_service(puma_runit_service_name, "force-stop", true)
        Capistrano::RunitBase.purge_service(puma_runit_service_name)
      end

    end
  end
end