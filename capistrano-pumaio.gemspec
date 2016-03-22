# Generated by juwelier
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Juwelier::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: capistrano-pumaio 3.1.3 ruby lib

Gem::Specification.new do |s|
  s.name = "capistrano-pumaio"
  s.version = "3.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Leif Ringstad"]
  s.date = "2016-03-22"
  s.description = "Capistrano recipes for puma using runit and monit."
  s.email = "leifcr@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README.md",
    "Rakefile",
    "VERSION",
    "capistrano-pumaio.gemspec",
    "lib/capistrano/helpers/puma/monit.rb",
    "lib/capistrano/helpers/puma/template_paths.rb",
    "lib/capistrano/puma.rb",
    "lib/capistrano/tasks/config.rake",
    "lib/capistrano/tasks/monit.rake",
    "lib/capistrano/tasks/runit.rake",
    "templates/monit/puma.conf.erb",
    "templates/puma-config.rb.erb",
    "templates/runit/control/q.erb",
    "templates/runit/finish.erb",
    "templates/runit/log/run.erb",
    "templates/runit/run.erb"
  ]
  s.homepage = "https://github.com/leifcr/capistrano-puma"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.5.1"
  s.summary = "Capistrano recipes for puma using runit and monit"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>, ["~> 3.4"])
      s.add_runtime_dependency(%q<activesupport>, [">= 4.0"])
      s.add_runtime_dependency(%q<capistrano-monit_runit>, ["~> 3.1.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.7"])
      s.add_development_dependency(%q<juwelier>, [">= 0"])
    else
      s.add_dependency(%q<capistrano>, ["~> 3.4"])
      s.add_dependency(%q<activesupport>, [">= 4.0"])
      s.add_dependency(%q<capistrano-monit_runit>, ["~> 3.1.0"])
      s.add_dependency(%q<bundler>, ["~> 1.7"])
      s.add_dependency(%q<juwelier>, [">= 0"])
    end
  else
    s.add_dependency(%q<capistrano>, ["~> 3.4"])
    s.add_dependency(%q<activesupport>, [">= 4.0"])
    s.add_dependency(%q<capistrano-monit_runit>, ["~> 3.1.0"])
    s.add_dependency(%q<bundler>, ["~> 1.7"])
    s.add_dependency(%q<juwelier>, [">= 0"])
  end
end

