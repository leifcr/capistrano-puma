require 'capistrano/base_helper/base_helper'
Capistrano::Configuration.instance(true).load do
  _cset :puma_runit_service_name, "puma"
  _cset :puma_workers, 2 # Must use a minimum of 1 worker (cluster mode, else restart/stop fails in the state file?)
  _cset :puma_min_threads, 2
  _cset :puma_max_threads, 8

  _cset :puma_bin, 'bundle exec puma'
  _cset :puma_control, 'bundle exec pumactl'

  # Control files
  _cset :puma_socket_file,  defer { "#{File.join(fetch(:sockets_path), "puma.sock")}" }
  _cset :puma_socket_url,   defer { "unix://#{fetch(:puma_socket_file)}" }
  _cset :puma_pid_file,     defer { File.join(fetch(:pids_path), "puma.pid") }
  _cset :puma_state_file,   defer { File.join(fetch(:sockets_path), "puma.state") }
  _cset :puma_control_file, defer { "#{File.join(fetch(:sockets_path), "pumactl.sock")}" }
  _cset :puma_control_url,  defer { "unix://#{fetch(:puma_control_file)}" }

  _cset :puma_use_preload_app, true # This must be set to false if phased restarts should be used

  _cset :puma_activate_control_app, true

  _cset :puma_on_restart_active, true

  # Logging to path
  _cset :puma_log_path, defer {"/var/log/service/#{fetch(:user)}/#{fetch(:application)}_#{Capistrano::BaseHelper.environment}/puma"}

  # Configuration files
  _cset :puma_local_config, File.join(File.expand_path(File.join(File.dirname(__FILE__),"../../../templates", "runit")), "config.rb.erb")

  # The remote location of puma's config file. Used by runit when starting puma
  _cset :puma_remote_config, defer {File.join(shared_path, "config", "puma.rb")}

  # runit defaults
  _cset :puma_restart_interval, defer {fetch(:runit_restart_interval)}
  _cset :puma_restart_count, defer {fetch(:runit_restart_count)}
  _cset :puma_autorestart_clear_interval, defer {fetch(:runit_autorestart_clear_interval)}

  # runit paths
  _cset :puma_runit_local_run, File.join(File.expand_path(File.join(File.dirname(__FILE__),"../../../templates", "runit", )), "run.erb")
  _cset :puma_runit_local_finish, File.join(File.expand_path(File.join(File.dirname(__FILE__),"../../../templates", "runit", )), "finish.erb")
  _cset :puma_runit_control_q, File.join(File.expand_path(File.join(File.dirname(__FILE__),"../../../templates", "runit")), "control-q.erb")
  _cset :puma_runit_local_log_run, File.join(File.expand_path(File.join(File.dirname(__FILE__),"../../../templates", "runit")), "log-run.erb")

  # monit configuration
  _cset :puma_monit_service_name,  defer { "#{fetch(:user)}_#{fetch(:application)}_#{Capistrano::BaseHelper.environment}_puma" }
  _cset :puma_monit_start_command, defer {"/bin/bash -c '[ ! -h #{Capistrano::RunitBase.service_path(fetch(:puma_runit_service_name))}/run ] || /usr/bin/sv start #{Capistrano::RunitBase.service_path(fetch(:puma_runit_service_name))}'"}
  _cset :puma_monit_stop_command,  defer {"/usr/bin/sv -w 12 force-stop #{Capistrano::RunitBase.service_path(fetch(:puma_runit_service_name))}"}
  _cset :puma_monit_memory_alert_threshold, "150.0 MB for 2 cycles"
  _cset :puma_monit_memory_restart_threshold, "175.0 MB for 3 cycles"
  _cset :puma_monit_cpu_alert_threshold,   "90% for 2 cycles"
  _cset :puma_monit_cpu_restart_threshold, "95% for 5 cycles"

  _cset :puma_local_monit_config, File.join(File.expand_path(File.join(File.dirname(__FILE__),"../../../templates", "monit")), "puma.conf.erb")

end