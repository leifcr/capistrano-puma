# Capistrano Recipes for Puma

This gem provides recipes for [Puma](http://puma.io) to setup [runit](http://smarden.org/runit/) and [monit](http://mmonit.com/monit) for both running and monitoring puma

## Versioning

Use 3.x for capistrano 3

For capistrano2, see the capistrano2 branch (will not be updated)

## Usage


Add it to your Gemfile in the development section.

```ruby
gem 'capistrano-pumaio', require: false
```

Now run ```bundle install```

Add this to your Capfile:

```ruby
require 'capistrano/puma'
```

### Monit

```ruby
cap puma:monit:disable          # Disable and stop monit services for puma
cap puma:monit:enable           # Enable monit services for puma
cap puma:monit:monitor          # Monitor puma
cap puma:monit:restart          # Restart monit services for puma
cap puma:monit:phased_restart   # Phased-Restart monit services for puma
cap puma:monit:setup            # Setup Puma monit-service
cap puma:monit:start            # Start monit services for puma (will also tr...
cap puma:monit:stop             # Stop monit services for puma (will also sto...
cap puma:monit:unmonitor        # Purge puma monit configuration
```

_Note about phased restarts:_

_It is not possible to have the application preloaded by puma when using phased restarts._
_You must therefore set the option :puma\_use\_preload\_app to to false in your deploy.rb_

_Like this:_

```ruby
set :puma_use_preload_app, false # If you are going to use phased restarts
```

#### Setup in your deploy file

You can add this to deploy.rb or env.rb in order to automatically start/stop puma using monit. It is not needed if you use runit to stop/start/restart the service.

```ruby
before "monit:unmonitor", "puma:monit:stop"
after  "monit:monitor",   "puma:monit:start"
```

### Runit

```ruby
cap puma:runit:disable          # Disable Puma runit-service
cap puma:runit:enable           # Enable Puma runit-service
cap puma:runit:flush_sockets    # Flush puma sockets, as they can end up 'han...
cap puma:runit:once             # Start Puma runit-service only ONCE (no supe...
cap puma:runit:purge            # Purge puma runit configuration
cap puma:runit:quit             # Quit the puma runit-service
cap puma:runit:restart          # Restart Puma runit-service
cap puma:runit:setup            # Setup Puma runit-service
cap puma:runit:start            # Start Puma runit-service
cap puma:runit:stop             # Stop Puma runit-service
```

#### Setup in your deploy file

To use runit to start/stop/restart services instead of monit, use the example below.

```ruby
# stop before deployment
# (must be done after monit has stopped monitoring the task. If not, the service will be restarted by monit)
before "monit:unmonitor", "puma:runit:stop"
# start before enabling monitor
before  "monit:monitor",   "puma:runit:start"
# restart before enabling monitor / monitoring has been started
before  "monit:monitor",   "puma:runit:restart"
```

### nginx

This has been removed, because it is better practice to setup nginx should as part of your infrastructure.

Most likely you have one or more load balancer and several app servers.

## Configuration of Monit/Runit

See puma/config.rb for default options, and ovveride any in your deploy.rb file.

## Contributing

* Fork the project
* Make a feature addition or bug fix
* Please test the feature or bug fix
* Make a pull request

## Copyright

(c) 2013 Leif Ringstad. See LICENSE for details
