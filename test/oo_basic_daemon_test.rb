require 'test/unit'

require File.join(File.dirname(__FILE__), '..', 'lib','basic_daemon')

#------------------------------------------------------------------------------#
# OO Testing
#------------------------------------------------------------------------------#

#----- Really needs to be in a helper file -----#
class MyDaemon < BasicDaemon
  def run
    foo = open("/tmp/out", "w")

    i = 1

    while true do
      foo.puts "loop: #{i}"
      foo.flush
      sleep 2

      i += 1
    end
  end
end

class TestSubclassedBasicDaemon < Test::Unit::TestCase
  def setup
    @mydaemon = MyDaemon.new
  end

  def test_creation_deletion_of_pidfile
    @mydaemon.start
    sleep 1 #----- give child proc time to create file
    assert File.exists?(@mydaemon.pidpath), "PID file at #{@mydaemon.pidpath} should exist"
    assert_match /^\d+$/, File.open(@mydaemon.pidpath, 'r').read, "PID should be numeric"

    @mydaemon.stop
    assert File.exists?(@mydaemon.pidpath) == false, "PID file at #{@mydaemon.pidpath} should not exist"
    assert @mydaemon.process_exists? == false, "Process should not exist"
  end

  def test_pidfile_removal_upon_termination
    @mydaemon.start
    sleep 1 #----- give child proc time to create file
    pid = File.open(@mydaemon.pidpath, 'r').read.to_i

    begin
      while true do
        Process.kill("TERM", pid)
        sleep(0.1)
      end
    rescue Errno::ESRCH
    end

    assert @mydaemon.process_exists? == false
    assert File.exists?(@mydaemon.pidpath) == false
  end

  def test_backgrounding_of_subclassed_daemon
    @mydaemon.start
    sleep 1 #----- give child proc time to create file
    assert @mydaemon.process_exists?
    @mydaemon.stop
    assert @mydaemon.process_exists? == false
  end
end

