Capistrano::Configuration.instance(true).load do
  _cset :puma_runit_service_name, "puma"
  _cset :puma_min_threads, 0
  _cset :puma_max_threads, 16

  _cset :puma_bin, 'bundle exec puma'
  _cset :puma_control, 'bundle exec pumactl'

  # Control files
  _cset :puma_socket_file, "#{File.join(fetch(:sockets_path), "puma.sock")}"
  _cset :puma_socket_url,  "unix://#{fetch(:puma_socket_file)}"
  _cset :puma_pid_file,    File.join(fetch(:pids_path),"#{app_server}.pid")
  _cset :puma_state_file,  File.join(fetch(:sockets_path), "puma.state")
  _cset :puma_control_file, "#{File.join(fetch(:sockets_path), "pumactl.sock")}"
  _cset :puma_control_url, "unix://#{fetch(:puma_control_file)}"

  _cset :puma_activate_control_app, true

  _cset :puma_on_restart_active, true

  # Logging to path
  _cset :puma_log_path, "/var/log/service/#{fetch(:user)}/#{fetch(:application)}/puma"

  # Configuration files
  _cset :puma_local_config, File.join(File.expand_path(File.join(File.dirname(__FILE__),"../templates")), "puma-config.rb.erb")

  # The remote location of puma's config file. Used by runit when starting puma
  _cset :puma_remote_config, File.join(shared_path, "config", "puma.rb")

  # runit paths
  _cset :puma_runit_local_config, File.join(File.expand_path(File.join(File.dirname(__FILE__),"../templates")), "puma-runit.erb")
  _cset :puma_runit_control_q, File.join(File.expand_path(File.join(File.dirname(__FILE__),"../templates")), "puma-runit-control-q.erb")
  _cset :puma_runit_local_log_run, File.join(File.expand_path(File.join(File.dirname(__FILE__),"../templates")), "puma-runit-log-run.erb")
end