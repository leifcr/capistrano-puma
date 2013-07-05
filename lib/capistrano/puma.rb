def try_require(library)
  begin
    require "#{library}"
  rescue LoadError => e
    puts "Capistrano-Puma: Cannot load library: #{library} Error: #{e}"
  end
end

try_require 'capistrano/puma/config'
try_require 'capistrano/puma/runit'
try_require 'capistrano/puma/monit'
