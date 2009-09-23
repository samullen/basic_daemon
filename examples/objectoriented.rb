#!/usr/bin/ruby

require File.join(File.dirname(__FILE__), '..', 'lib','basic_daemon')
require 'pp'

basedir = "/tmp" # change this to where you want to deal with things
pidfile = File.basename($PROGRAM_NAME, File.extname($PROGRAM_NAME))

class MyDaemon < BasicDaemon
  def run
    foo = open("/tmp/out", "w")

    i = 1

    while true do
      foo.puts "loop: #{i}"
      foo.flush
      sleep 5

      i += 1
    end
  end
end

d = MyDaemon.new(:pidfile => pidfile, :piddir => basedir, :workingdir => basedir)

if ARGV[0] == 'start'
  puts "Should print 'got here' on the next line"
  d.start
elsif ARGV[0] == 'stop'
  d.stop
  exit!
elsif ARGV[0] == 'restart'
  d.restart
else
  STDERR.puts "wrong! use start or stop."
  exit!
end

puts 'got here'
exit
