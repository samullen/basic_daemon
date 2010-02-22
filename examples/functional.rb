#!/usr/bin/ruby

require File.join(File.dirname(__FILE__), '..', 'lib','basic_daemon')

basedir = "/tmp" # change this to where you want to deal with things
pidfile = File.basename($PROGRAM_NAME, File.extname($PROGRAM_NAME))

d = BasicDaemon.new({:pidfile => pidfile, :piddir => basedir, :workingdir => basedir})

process = Proc.new do
  i = 1
  foo = open(basedir + "/out", "w")

  while true do
    foo.puts "loop: #{i}"
    foo.flush
    sleep 5

    i += 1
  end
end

if ARGV[0] == 'start'
  d.start &process
elsif ARGV[0] == 'stop'
  d.stop
  exit!
elsif ARGV[0] == 'restart'
  d.restart &process
else
  STDERR.puts "wrong! Use start, stop, or restart."
  exit!
end

exit
