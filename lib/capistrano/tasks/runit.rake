after 'deploy:setup', 'puma:runit:setup'

# enable service after update in case it has not been setup or is disabled
# Service should probably be started as well?
after 'deploy:update', 'puma:runit:enable'
before 'puma:runit:setup', 'puma:flush_sockets'
before 'puma:runit:setup', 'puma:setup'
before 'puma:runit:quit', 'puma:runit:stop'

namespace :puma do
  desc 'Setup Puma configuration'
  task :setup do
    if test("[ ! -d #{fetch(:sockets_path)} ]")
      execute :mkdir, "-p #{sockets_path}"
    end
    upload! template_to_s_io(fetch(:puma_config_template)), fetch(:puma_config_file)
  end

  desc 'Flush Puma sockets, as they can end up \'hanging around\''
  task :flush_sockets do
    execute :rm, "-f #{fetch(:puma_socket_file)}"
    execute :rm, "-f #{fetch(:puma_control_file)}"
  end

  namespace :runit do
    desc 'Setup Puma runit-service'
    task :setup do
      # Create runit config
      if test("[ ! -d #{runit_service_path(fetch(:puma_runit_service_name))} ]")
        execute :mkdir, "-p #{runit_service_path(fetch(:puma_runit_service_name))}"
      end

      upload! template_to_s_io(fetch(:puma_config_template)), fetch(:puma_config_file)
      upload! template_to_s_io(fetch(:puma_runit_run_template)), runit_service_run_file(fetch(:puma_runit_service_name))
      upload! template_to_s_io(fetch(:puma_runit_finish_template)), runit_service_finish_file(fetch(:puma_runit_service_name)) # rubocop:disable Metrics/LineLength

      # must use quit script for stop as well, to ensure quit and stop performs equally
      upload! template_to_s_io(fetch(:puma_runit_control_q_template)), runit_service_control_file(fetch(:puma_runit_service_name, 'q')) # rubocop:disable Metrics/LineLength
      upload! template_to_s_io(fetch(:puma_runit_control_q_template)), runit_service_control_file(fetch(:puma_runit_service_name, 's')) # rubocop:disable Metrics/LineLength

      # Log scripts for runit service
      if test("[ ! -d #{runit_service_log_path(fetch(:puma_runit_service_name))} ]")
        execute :mkdir, "-p #{runit_service_log_path(fetch(:puma_runit_service_name))}"
      end

      upload! template_to_s_io(fetch(:puma_runit_log_run_template)), runit_service_log_run_file(fetch(:puma_runit_service_name)) # rubocop:disable Metrics/LineLength

      # Make scripts executable
      runit_set_executable_files(fetch(:puma_runit_service_name))

      # Create log paths for the service
      if test("[ ! -d #{runit_var_log_service_single_service_path(fetch(:puma_runit_service_name))} ]")
        execute :mkdir, "-p #{runit_var_log_service_single_service_path(fetch(:puma_runit_service_name))}"
      end
    end

    desc 'Enable Puma runit-service'
    task :enable do
      enable_service(fetch(:puma_runit_service_name))
    end

    desc 'Disable Puma runit-service'
    task :disable do
      disable_service(fetch(:puma_runit_service_name))
    end

    desc 'Start Puma runit-service'
    task :start do
      control_service(fetch(:puma_runit_service_name), 'start')
    end

    desc 'Start Puma runit-service only ONCE (no supervision...)'
    task :once do
      control_service(fetch(:puma_runit_service_name), 'once')
    end

    desc 'Stop Puma runit-service'
    # :on_error => :continue  should be added when cap3 equivalent has been figured out
    task :stop do
      # have to use force-stop on failed stop, since puma might not terminate properly depending on current
      # 'slow' clients.
      # will wait 30 seconds for puma to shut down, to allow it to serve any on-going requests
      control_service(fetch(:puma_runit_service_name), 'force-stop', '-w 30')
    end

    desc 'Quit the puma runit-service'
    # :on_error => :continue  should be added when cap3 equivalent has been figured out
    task :quit do
      control_service(fetch(:puma_runit_service_name), 'quit')
    end

    desc 'Restart Puma runit-service'
    task :restart do
      # It is not possible to see if a restart is in progress using the pumactl tool as of now.

      # restarting = false
      # # check if puma is already performing a restart
      # invoke_command("cd #{fetch(:current_path)}; [[ $(#{fetch(:puma_control)} -S #{fetch(:puma_state_file)} status) == *restart* ]] && echo 'restarting';true") do |ch, stream, out| # rubocop:disable Metrics/LineLength
      #   result = (/restart/ =~ out)
      # end
      # restarting = true unless result.nil?
      # result     = nil

      # if restarting == false
      # check if it is running
      started = false
      within(current_path) do
        a = capture(fetch(:puma_control), "-S #{fetch(:puma_state_file)} status)")
        started = a.includes?('started')
      end

      if started == true
        info("\nRestarting puma")
        # Send USR2 to puma in order to restart it....
        control_service(fetch(:puma_runit_service_name), '2')
      else
        info("\nStarting puma, (wasn't running before)")
        control_service(fetch(:puma_runit_service_name), 'start')
      end
      # end
    end

    desc 'Phased Restart of Puma'
    task :phased_restart do
      started = false
      within(current_path) do
        a = capture(fetch(:puma_control), "-S #{fetch(:puma_state_file)} status)")
        started = a.includes?('started')
      end

      if started == true
        # Send USR1 to puma in order to restart it....
        info("\nPhased restart of puma")
        control_service(fetch(:puma_runit_service_name), '1')
      else
        important("\nStarting puma, (wasn't running before)")
        control_service(fetch(:puma_runit_service_name), 'start')
      end
    end

    desc 'Purge Puma runit configuration'
    # :on_error => :continue  should be added when cap3 equivalent has been figured out
    task :purge do
      disable_service(fetch(:puma_runit_service_name))
      purge_service(fetch(:puma_runit_service_name))
    end
  end
end
