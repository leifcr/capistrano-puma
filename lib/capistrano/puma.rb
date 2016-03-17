def try_require(library)
  begin
    require "#{library}"
  rescue LoadError => e
    puts "Capistrano-Puma: Cannot load library: #{library} Error: #{e}"
  end
end

try_require 'capistrano/monit'
try_require 'capistrano/runit'
load File.expand_path('../tasks/config.rake', __FILE__)
load File.expand_path('../tasks/monit.rake', __FILE__)
load File.expand_path('../tasks/runit.rake', __FILE__)
