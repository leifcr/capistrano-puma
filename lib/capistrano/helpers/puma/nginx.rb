module Capistrano
  module Helpers
    module Puma
      module Nginx
        def default_pw_generator
          pw = SecureRandom.random_number(36**10).to_s(36).rjust(10, '0')
          info "Random password generated: #{pw}"
          pw
        end
      end
    end
  end
end
