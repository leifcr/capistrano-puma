# Capistrano Recipes for Puma

This gem provides recipes for [Puma](http://puma.io) to setup [runit](smarden.org/runit/), [monit](http://mmonit.com/monit) and [nginx](http://nginx.org) for both running and monitoring puma and a nginx site connected to a puma socket

## Usage


Add it to your Gemfile without requiring it

```ruby
gem 'capistrano-pumaio'
```

In your deploy.rb:

```ruby
require 'capistrano/puma'
```


### Monit

```ruby
cap puma:monit:disable          # Disable and stop monit services for puma
cap puma:monit:enable           # Enable monit services for puma
cap puma:monit:monitor          # Monitor puma
cap puma:monit:restart          # Restart monit services for puma
cap puma:monit:setup            # Setup Puma monit-service
cap puma:monit:start            # Start monit services for puma (will also tr...
cap puma:monit:stop             # Stop monit services for puma (will also sto...
cap puma:monit:unmonitor        # Purge puma monit configuration
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

#### Specific to puma and nginx for the application:

```ruby
cap puma:nginx:disable          # Disable nginx site for the application
cap puma:nginx:enable           # Enable nginx site for the application
cap puma:nginx:purge            # Purge nginx site config for the application
cap puma:nginx:setup            # Parses and uploads nginx configuration for this app.
```

#### Global nginx commands

```ruby
cap nginx:restart               # Restart nginx
cap nginx:start                 # Start nginx
cap nginx:status                # Show nginx status
cap nginx:stop                  # Stop nginx
```

#### Configuration for nginx

See nginx.rb for configuration options.

#### Notes when using nginx


puma:nginx:setup is setup to run automatically after deploy:setup, and you will be asked if you want to enable the site.

If you do not enable the site during setup, be sure to run the following two commands when you want to enable your site:

```ruby
cap puma:nginx:enable
cap nginx:restart
```


## Configuration of Monit/Runit

See puma/config.rb for default options, and ovveride any in your deploy.rb file.

## Contributing

* Fork the project
* Make a feature addition or bug fix
* Please test the feature or bug fix
* Make a pull request

## Copyright

(c) 2013 Leif Ringstad. See LICENSE for details
