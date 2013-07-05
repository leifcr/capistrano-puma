# Capistrano Recipes for Puma

This gem provides recipes for [Puma](http://puma.io) to setup runit and monit

## Usage

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

## Configuration

See puma/config.rb for default options, and ovveride any in your deploy.rb file.

## Contributing

* Fork the project
* Make a feature addition or bug fix
* Please test the feature or bug fix
* Make a pull request

## Copyright

(c) 2013 Leif Ringstad. See LICENSE for details
