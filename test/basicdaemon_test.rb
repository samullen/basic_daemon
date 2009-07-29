# test/basicdaemon_test.rb

require File.join(File.dirname(__FILE__), '..', 'lib','basic_daemon')
require 'test/unit'

class BasicDaemonTest < Test::Unit::TestCase

def setup
  @daemon = BasicDaemon.new({:piddir => '/tmp', :workingdir => '/tmp'})
end

def test_generic_init
  d = BasicDaemon.new

  assert_equal '/tmp/basicdaemon_test', d.pidpath
  assert_equal '/tmp', d.piddir
  assert_equal '/', d.workingdir
end

def test_specific_init
  d = BasicDaemon.new({:pidfile => 'foo', :piddir => '/var/lock', :workingdir => '/var/lock'})
  assert_equal '/var/lock', d.piddir
  assert_equal '/var/lock/foo', d.pidpath
  assert_equal '/var/lock', d.workingdir
end

def test_attribute_changes
  d = BasicDaemon.new({:pidfile => "foo.txt"})

  assert_equal '/tmp', d.piddir = '/tmp'
  assert_equal '/tmp/foo.txt', d.pidpath
  d.pidfile = "bar.txt"
  assert_equal '/tmp/bar.txt', d.pidpath
  assert_equal '/etc', d.workingdir = '/etc'
end

# def test_pidfile_creation_deletion
#   pid = nil
# 
#   d = BasicDaemon.new
#   d2 = BasicDaemon.new
#   d.start
# 
#   #----- testing creation of pid file -----#
#   assert File.exists?("/tmp/basicdaemon_test")
# 
#   open("/tmp/basicdaemon_test", "r") do |f|
#     pid = f.read.to_i
#   end
#   assert_equal d.pid, pid
# 
# #   d2.stop
# 
# #   flunk File.exists?("/tmp/basicdaemon_test")
# end

end
