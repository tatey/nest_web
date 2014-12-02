# Nest Web

Programatically interact with your Nest accout using Ruby. Based on
the Chrome Extension for Nest.

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
structure.away_status # => "home"
structure.set_away_status("away")
structure.away_status # => "away"
```
