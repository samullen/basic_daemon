require 'test/unit'

require File.join(File.dirname(__FILE__), '..', 'lib','basic_daemon')

class TestFunctionalBasicDaemon < Test::Unit::TestCase
  def setup
    @daemon = BasicDaemon.new

    @process = Proc.new do
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

  def test_creation_deletion_of_pidfile
    @daemon.start &@process

    sleep 1 #----- give child proc time to create file
    assert File.exists?(@daemon.pidpath), "PID file at #{@daemon.pidpath} should exist"
    assert_match /^\d+$/, File.open(@daemon.pidpath, 'r').read, "PID should be numeric"

    @daemon.stop
    assert File.exists?(@daemon.pidpath) == false, "PID file at #{@daemon.pidpath} should not exist"
    assert @daemon.process_exists? == false, "Process should not exist"
  end

  def test_pidfile_removal_upon_termination
    @daemon.start &@process
    sleep 1 #----- give child proc time to create file
    pid = File.open(@daemon.pidpath, 'r').read.to_i

    begin
      while true do
        Process.kill("TERM", pid)
        sleep(0.1)
      end
    rescue Errno::ESRCH
    end

    assert @daemon.process_exists? == false
    assert File.exists?(@daemon.pidpath) == false
  end

  def test_backgrounding_of_subclassed_daemon
    @daemon.start &@process
    sleep 1 #----- give child proc time to create file
    assert @daemon.process_exists?
    @daemon.stop
    assert @daemon.process_exists? == false
  end
end
