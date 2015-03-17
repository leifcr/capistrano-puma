after "monit:setup", "puma:monit:setup"
after "puma:monit:setup", "puma:monit:enable"
after "puma:monit:enable", "monit:reload"

before "puma:monit.disable", "puma:monit:unmonitor"
after  "puma:monit:disable", "monit:reload"

# start service after update in case it has not been stopped
# after "deploy:update", "puma:monit:start"
# Not needed?

namespace :puma do
  namespace :monit do
    desc 'MONIT: Setup Puma service'
    task :setup, :roles => [:app, :web, :db] do
      # Upload configuration
      Capistrano::BaseHelper::generate_and_upload_config(puma_local_monit_config, File.join(fetch(:monit_available_path), "#{fetch(:puma_runit_service_name)}.conf"))
      # Enable monitor
    end

    desc 'MONIT: Enable services for Puma'
    task :enable, :roles => [:app, :web, :db] do
      enable_service("#{fetch(:puma_runit_service_name)}.conf")
    end

    desc 'MONIT: Disable and Stop services for Puma'
    task :disable, :roles => [:app, :web, :db] do
      disable_service("#{fetch(:puma_runit_service_name)}.conf")
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
