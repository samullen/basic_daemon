class BasicDaemon
  attr_accessor :pidfile, :piddir, :workingdir

  def initialize(pidfile, piddir="/var/lock", workingdir="/")
    @pidfile = piddir + "/" + pidfile
    @workingdir = workingdir

    at_exit do
      self.delpid
    end
  end

#------------------------------------------------------------------------------#
  def start
    pid = nil

    begin
      pid = open(@pidfile, 'r').read
    rescue => e
    end

    if pid
      STDERR.puts "pidfile #{@pidfile} already exists. Daemon already running?"
      exit!
    end

    self.daemonize
  end
  
#------------------------------------------------------------------------------#
  def daemonize
    pid = nil

    #----- Fork off from the calling process -----#
    begin
      fork && exit!
    rescue => e
      STDERR.puts "Error: Failed to fork primary parent: \n\t: " +
        "(#{e.class}) #{e.message} "
      exit!
    end

    Process.setsid #----- make forked process session leader

    #----- Fork off from the calling forked sub-process -----#
    begin
      fork && exit!
    rescue => e
      STDERR.puts "Error: Failed to fork daemon: \n\t(#{e.class}) #{e.message}"
      exit!
    end

    Dir.chdir @workingdir #----- chdir to working directory
    File.umask 0000 #----- clear out file mode creation mask
    STDIN.reopen("/dev/null")
    STDOUT.reopen("/dev/null", "w")
    STDERR.reopen("/dev/null", "w")

    begin
      open(@pidfile, "w") do |f|
        f.puts Process.pid
      end
    rescue
      STDERR.puts "Error: Unable to open #{@pidfile} for writing:\n\t" +
        "(#{e.class}) #{e.message}"
    end
  end

#------------------------------------------------------------------------------#
  def stop
    pid = nil

    begin
      open(@pidfile, "r") do |f|
        pid = f.read.to_i
      end
    rescue
      STDERR.puts "Error: Unable to open #{@pidfile} for reading:\n\t" +
        "(#{e.class}) #{e.message}"
    end

    unless pid
      STDERR.puts "pidfile #{@pidfile} does not exist. Daemon not running?\n"
      return # not an error in a restart
    end

    begin
      while true do
        Process.kill("TERM", pid)
        sleep(0.1)
      end
    rescue => e
      unless e.class == Errno::ESRCH
        STDERR.puts "unable to terminate process: (#{e.class}) #{e.message}"
        exit!
      end
    end
  end

#------------------------------------------------------------------------------#
  def restart
    self.stop
    self.start
  end

#------------------------------------------------------------------------------#
  def delpid
    begin
      File.unlink(@pidfile)
    rescue => e
      STDERR.puts "ERROR: Unable to unlink #{@pidfile}: (#{e.class}) #{e.message}"
      exit
    end
  end
end
