class BasicDaemon
  attr_accessor :pidfile, :piddir, :workingdir

  VERSION = '0.0.2'

  DEFAULT_OPTIONS = {
    :pidfile => File.basename($PROGRAM_NAME, File.extname($PROGRAM_NAME)),
    :piddir => '/var/lock',
    :workingdir => '/'
  }

  def initialize(*args)
    opts = {}

    case
    when args.length == 0 then
    when args.length == 1 then
      arg = args.shift

      if arg.class == Hash
        opts = arg
      end
    else
      raise ArgumentError, "new() expects hash or hashref as argument"
    end

    opts = DEFAULT_OPTIONS.merge opts

    @piddir     = opts[:piddir]
    @pidfile    = @piddir + '/' + opts[:pidfile]
    @workingdir = opts[:workingdir]
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

    at_exit do
      self.delpid
    end

    self.daemonize
    self.run

#     unless block_given?
#       self.run
#     else
#       yield
#     end
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

    Dir::chdir(@workingdir) #----- chdir to working directory
    File::umask(0) #----- clear out file mode creation mask
    STDIN.reopen("/dev/null", 'r')
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

  def run
  end
end
