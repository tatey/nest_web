# Nest Web

Programatically interact with your [Nest developer](https://developer.nest.com) account using Ruby.
Based on the [Nest Developer Tool](https://chrome.google.com/webstore/detail/nest-developer-tool/dcmagkgecphmneocilhoihpoibfddfjl) extension for Google Chrome.

Unfortunately you cannot set the CO or smoke alarm states using
the public API. We use this to programatically test an app we built
on top of [Nest's public API](https://developer.nest.com/documentation/api-reference).

## Install

First, add this line to your application's Gemfile.

``` ruby
gem 'nest_web', github: 'tatey/nest_web'
```

Then, install the gem.

```
$ bundle
```

## Usage

Change a structure's away status.

``` ruby
session = NestWeb.login('you@email.com', 'secret')
structure = session.structures.first
structure.name # => "Office"
structure.away_status # => "home"
structure.set_away_status("away")
structure.away_status # => "away"
```

Change a device's CO alarm state.

``` ruby
session = NestWeb.login('you@email.com', 'secret')
structure = session.structures.first
device = structure.devices.first
device.serial_number # => "D383A9343444444A"
device.co_alarm_state # => "ok"
device.set_co_alarm_state("warning")
device.co_alarm_state # => "warning"
```

Exception handling.

``` ruby
begin
  # ...
  device.set_co_alarm_state("warning")
rescue NestWeb::Error => error
  puts error
end
```
