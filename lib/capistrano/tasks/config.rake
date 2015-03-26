require 'capistrano/runit'
require 'capistrano/helpers/puma/template_paths'
include Capistrano::DSL::BasePaths
include Capistrano::DSL::RunitPaths
include Capistrano::Helpers::Base
include Capistrano::Helpers::Runit

namespace :load do
  task :defaults do
    # Puma Configuration
    set :puma_runit_service_name, 'puma'
    set :puma_workers, 2 # Must use a minimum of 1 worker (cluster mode, else restart/stop fails in the state file?)
    set :puma_min_threads, 8
    set :puma_max_threads, 8

    set :puma_bin, 'bundle exec puma'
    set :puma_control, 'bundle exec pumactl'

    # Control files
    set :puma_socket_file,  proc { "#{File.join(fetch(:sockets_path), 'puma.sock')}" }
    set :puma_socket_url,   proc { "unix://#{fetch(:puma_socket_file)}" }
    set :puma_pid_file,     proc { File.join(fetch(:pids_path), 'puma.pid') }
    set :puma_state_file,   proc { File.join(fetch(:sockets_path), 'puma.state') }
    set :puma_control_file, proc { "#{File.join(fetch(:sockets_path), 'pumactl.sock')}" }
    set :puma_control_url,  proc { "unix://#{fetch(:puma_control_file)}" }

    # This must be set to false if phased restarts should be used
    set :puma_use_preload_app, false

    set :pruma_prune_bundler, true

    set :puma_activate_control_app, true

    set :puma_on_restart_active, true

    # Logging to path
    set :puma_log_path, proc { runit_var_log_service_single_service_path(fetch(:puma_runit_service_name)) }

    # Configuration files
    set :puma_config_template, File.join(Capistrano::Helpers::Puma::TemplatePaths.template_base_path, 'puma-config.rb.erb')

    # The remote location of puma's config file. Used by runit when starting puma
    set :puma_remote_config_folder, proc { shared_path.join('config') }
    set :puma_config_file, proc { File.join(fetch(:puma_remote_config_folder), 'puma.rb') }

    # runit defaults
    set :puma_restart_interval, proc { fetch(:runit_restart_interval) }
    set :puma_restart_count, proc { fetch(:runit_restart_count) }
    set :puma_autorestart_clear_interval, proc { fetch(:runit_autorestart_clear_interval) }

    # runit paths
    set :puma_runit_run_template, File.join(Capistrano::Helpers::Puma::TemplatePaths.template_base_path, 'runit', 'run.erb')
    set :puma_runit_finish_template, File.join(Capistrano::Helpers::Puma::TemplatePaths.template_base_path, 'runit', 'finish.erb') # rubocop:disable Metrics/LineLength
    set :puma_runit_control_q_template, File.join(Capistrano::Helpers::Puma::TemplatePaths.template_base_path, 'runit', 'control', 'q.erb') # rubocop:disable Metrics/LineLength
    set :puma_runit_log_run_template, File.join(Capistrano::Helpers::Puma::TemplatePaths.template_base_path, 'runit', 'log', 'run.erb') # rubocop:disable Metrics/LineLength

    # monit configuration
    set :puma_monit_service_name,  proc { "#{user_app_env_underscore}_puma" }
    set :puma_monit_start_command, proc { "/bin/bash -c '[ ! -h #{runit_service_path(fetch(:puma_runit_service_name))}/run ] || /usr/bin/sv start #{runit_service_path(fetch(:puma_runit_service_name))}'" } # rubocop:disable Metrics/LineLength
    set :puma_monit_stop_command,  proc { "/usr/bin/sv -w 12 force-stop #{runit_service_path(fetch(:puma_runit_service_name))}" } # rubocop:disable Metrics/LineLength
    set :puma_monit_memory_alert_threshold, '150.0 MB for 2 cycles'
    set :puma_monit_memory_restart_threshold, '175.0 MB for 3 cycles'
    set :puma_monit_cpu_alert_threshold,   '90% for 2 cycles'
    set :puma_monit_cpu_restart_threshold, '95% for 5 cycles'

    set :puma_monit_config_template, File.join(Capistrano::Helpers::Puma::TemplatePaths.template_base_path, 'monit', 'puma.conf.erb') # rubocop:disable Metrics/LineLength
  end
end
