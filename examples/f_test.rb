#!/usr/bin/ruby

STDERR.puts "this won't work until I get the block stuff working."
exit

require File.join(File.dirname(__FILE__), '..', 'lib','basic_daemon')

basedir = "/tmp" # change this to where you want to deal with things
pidfile = File.basename($PROGRAM_NAME, File.extname($PROGRAM_NAME))

d = BasicDaemon.new({:pidfile => pidfile, :piddir => basedir, :workingdir => basedir})

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

foo = open(basedir + "/out", "w")

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
