#!/usr/bin/ruby

require 'lib/basic_daemon'
require 'pp'

class MyDaemon < BasicDaemon
  def run
    foo = open("/home/smullen/dev/BasicDaemon/out", "w")

    i = 1

    while true do
      foo.puts "loop: #{i}"
      foo.flush
      sleep 5

      i += 1
    end
  end
end

d = MyDaemon.new({:pidfile => 'pidfile.txt', :piddir => '/home/smullen/dev/BasicDaemon', :workingdir => '/home/smullen/dev/BasicDaemon'})

if ARGV[0] == 'start'
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

exit
