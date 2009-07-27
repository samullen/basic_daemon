# test/basicdaemon_test.rb

require File.join(File.dirname(__FILE__), '..', 'lib','basic_daemon')
require 'test/unit'

class BasicDaemonTest < Test::Unit::TestCase

def setup
  @daemon = BasicDaemon.new
end

def test_generic_init
  assert_equal '/var/lock/basicdaemon_test', @daemon.pidfile
  assert_equal '/var/lock', @daemon.piddir
  assert_equal '/', @daemon.workingdir
end

def test_specific_init
  d = BasicDaemon.new({:pidfile => 'foo', :piddir => '/tmp', :workingdir => '.'})
  assert_equal '/tmp', d.piddir
  assert_equal '/tmp/foo', d.pidfile
  assert_equal '.', d.workingdir
end

def test_start
end

end
