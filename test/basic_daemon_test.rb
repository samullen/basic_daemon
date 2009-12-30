require 'test/unit'

require File.join(File.dirname(__FILE__), '..', 'lib','basic_daemon')

class TestWithDefaults < Test::Unit::TestCase
  def setup
    @daemon = BasicDaemon.new
  end

  def test_should_default_pidfile_to_program_name
    file_sans_ext = File.basename($PROGRAM_NAME, File.extname($PROGRAM_NAME))
    message = "#{@daemon.pidfile} and #{file_sans_ext} are not equal"

    assert_equal @daemon.pidfile, file_sans_ext, message
  end

  def test_should_default_piddir_to_tmp
    message = "PID Directory #{@daemon.piddir} should default to '/tmp'"

    assert_equal @daemon.piddir, "/tmp", message
  end

  def test_should_default_working_directory_to_root
    message = "Working Directory #{@daemon.workingdir} should default to '/'"

    assert_equal @daemon.workingdir, "/", message
  end

  def test_update_of_pidfile
    message = "PID File should be set to 'foo.txt'"
    new_pidfile = 'foo.txt'

    @daemon.pidfile = new_pidfile
    assert_equal @daemon.pidfile, new_pidfile, message
    assert_equal @daemon.pidpath, "/tmp/#{new_pidfile}", message
  end

  def test_stopping_of_unstarted_daemon
  end
end

class TestWithSuppliedValues < Test::Unit::TestCase
  def setup
    @daemon = BasicDaemon.new({:pidfile => 'foo', :piddir => '/var/lock', :workingdir => '/var/lock'})
  end

  def test_should_default_pidfile_to_foo
    message = "#{@daemon.pidfile} and 'foo' are not equal"

    assert_equal @daemon.pidfile, "foo", message
  end

  def test_should_default_piddir_to_varlock
    message = "PID Directory #{@daemon.piddir} should default to '/var/lock'"

    assert_equal @daemon.piddir, "/var/lock", message
  end

  def test_should_default_piddir_to_varlockfoo
    message = "PID Path #{@daemon.pidpath} should default to '/var/lock/foo'"

    assert_equal @daemon.pidpath, "/var/lock/foo", message
  end

  def test_should_default_working_directory_to_varlock
    message = "Working Directory #{@daemon.workingdir} should default to '/var/lock'"

    assert_equal @daemon.workingdir, "/var/lock", message
  end
end

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

#------------------------------------------------------------------------------#
# Functional Testing
#------------------------------------------------------------------------------#

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
