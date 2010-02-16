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

  def teardown
    @mydaemon.process_exists? && @mydaemon.stop
  end

#------------------------------------------------------------------------------#
  def test_creation_deletion_of_pidfile
    assert_nil @mydaemon.pid, "pidfile shouldn't exist so pid should be nil."

    @mydaemon.start
    sleep 0.1 #----- give child proc time to create file

    assert File.exists?(@mydaemon.pidpath), "PID file at #{@mydaemon.pidpath} should exist"
    assert_match(/^\d+$/, File.open(@mydaemon.pidpath, 'r').read, "PID should be numeric")

    @mydaemon.stop
    assert File.exists?(@mydaemon.pidpath) == false, "PID file at #{@mydaemon.pidpath} should no longer exist"
    assert @mydaemon.process_exists? == false, "Process should no longer exist."
  end

#------------------------------------------------------------------------------#
  def test_pidfile_removal_upon_termination
    @mydaemon.start
    sleep 0.1 #----- give child proc time to create file

    begin
      while true do
        Process.kill("TERM", @mydaemon.pid)
        sleep(0.1)
      end
    rescue Errno::ESRCH
    end

    assert @mydaemon.process_exists? == false, "External termination of the process should register with the daemon."
    assert File.exists?(@mydaemon.pidpath) == false, "pidfile should be deleted when the process is terminated externally"
  end

#------------------------------------------------------------------------------#
  def test_backgrounding_of_subclassed_daemon
    @mydaemon.start
    sleep 0.1 #----- give child proc time to create file
    assert @mydaemon.process_exists?
    @mydaemon.stop
    assert @mydaemon.process_exists? == false
  end

#------------------------------------------------------------------------------#
  def test_restart
    @mydaemon.start
    sleep 0.1
    assert @mydaemon.process_exists?
    previous_pid = @mydaemon.pid

    @mydaemon.restart
    sleep 0.1
    assert @mydaemon.process_exists?
    assert previous_pid != @mydaemon.pid
  end
end

