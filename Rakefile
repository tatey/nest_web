#!/usr/bin/env rake
require 'bundler/gem_tasks'

task :console do
  $LOAD_PATH << 'lib'
  require 'nest_web'
  require 'pry'

  ARGV.clear
  Pry.start
end
