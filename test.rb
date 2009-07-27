require 'lib/basic_daemon'
require 'pp'

d = BasicDaemon.new({:pidfile => 'foo', :piddir => '/tmp', :workingdir => '.'})

pp d
puts File.basename(__FILE__, File.extname(__FILE__))
puts File.basename($PROGRAM_NAME, File.extname($PROGRAM_NAME))
