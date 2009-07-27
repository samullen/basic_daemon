#!/usr/bin/ruby

require 'lib/basic_daemon'
require 'pp'

d = BasicDaemon.new({:pidfile => 'pidfile.txt', :piddir => "/home/smullen/dev/BasicDaemon", :workingdir => "/home/smullen/dev/BasicDaemon" })
# d = Daemonate.new('pidfile.txt', "/etc")

# if ARGV[0] == 'start'
#   d.start
# elsif ARGV[0] == 'stop'
#   d.stop
#   exit!
# elsif ARGV[0] == 'restart'
#   d.restart
# else
#   STDERR.puts "wrong! use start or stop."
#   exit!
# end

foo = open("/home/smullen/dev/BasicDaemon/out", "w")

d.start do
  i = 1

  while true do
    foo.puts "loop: #{i}"
    foo.flush
    sleep 5

    i += 1
  end
end

exit
