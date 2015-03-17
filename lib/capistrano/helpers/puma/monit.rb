module Capistrano
  module Helpers
    module Puma
      ##
      # Module Monit provides helpers for Monit/Puma combination
      ##
      module Monit
        def available_configuration_with_path
          File.join(fetch(:monit_available_path), "#{fetch(:puma_runit_service_name)}.conf")
        end

        def available_configuration_file
          "#{fetch(:puma_runit_service_name)}.conf"
        end
      end
    end
  end
end
