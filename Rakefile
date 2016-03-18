# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end
require 'rake'

require 'juwelier'
Juwelier::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = 'capistrano-pumaio'
  gem.homepage = 'https://github.com/leifcr/capistrano-puma'
  gem.license = 'MIT'
  gem.summary = 'Capistrano recipes for puma using runit and monit'
  gem.description = 'Capistrano recipes for puma using runit and monit.'
  gem.email = 'leifcr@gmail.com'
  gem.authors = ['Leif Ringstad']
  gem.files.exclude '.ruby-*'
  gem.files.exclude '*.sublime-project'
  gem.files.exclude '.rubocop.yml'
  # dependencies defined in Gemfile
end
Juwelier::RubygemsDotOrgTasks.new

# require 'rdoc/task'
# Rake::RDocTask.new do |rdoc|
#   version = File.exist?('VERSION') ? File.read('VERSION') : ''

#   rdoc.rdoc_dir = 'rdoc'
#   rdoc.title = 'capistrano-empty #{version}'
#   rdoc.rdoc_files.include('README*')
#   rdoc.rdoc_files.include('lib/**/*.rb')
# end
