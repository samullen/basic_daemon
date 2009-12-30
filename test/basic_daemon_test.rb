require 'test/unit'

require File.join(File.dirname(__FILE__), '..', 'lib','basic_daemon')

class TestBasicDaemon < Test::Unit::TestCase
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

