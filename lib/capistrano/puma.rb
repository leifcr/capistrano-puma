# def try_require(library)
#   begin
#     require "#{library}"
#   rescue LoadError => e
#     puts "Capistrano-Puma: Cannot load library: #{library} Error: #{e}"
#   end
# end

# try_require 'tasks/config.rake'
# try_require 'tasks/monit.rake'
# try_require 'tasks/runit.rake'
# try_require 'tasks/nginx_config.rake'
# try_require 'tasks/nginx.rake'
# try_require 'tasks/.rake'
load File.expand_path('../tasks/config.rake', __FILE__)
load File.expand_path('../tasks/monit.rake', __FILE__)
load File.expand_path('../tasks/runit.rake', __FILE__)
load File.expand_path('../tasks/nginx_config.rake', __FILE__)
load File.expand_path('../tasks/nginx.rake', __FILE__)
