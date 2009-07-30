class BasicDaemon
  attr_accessor :workingdir, :pidfile, :piddir
  attr_reader :pid

  VERSION = '0.0.4'

  DEFAULT_OPTIONS = {
    :pidfile => File.basename($PROGRAM_NAME, File.extname($PROGRAM_NAME)),
    :piddir => '/tmp',
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
    @pidfile    = opts[:pidfile]
    @workingdir = opts[:workingdir]
    @pid        = nil
  end

  def pidpath
    @piddir + '/' + @pidfile
  end

#------------------------------------------------------------------------------#
  def start
    begin
      @pid = open(self.pidpath, 'r').read
    rescue Errno::EACCES => e
      STDERR.puts "Error: unable to open file #{self.pidpath} for reading:\n\t"+
        "(#{e.class}) #{e.message}"
      exit!
    rescue => e
    end

    if @pid
      STDERR.puts "pidfile #{self.pidpath} with pid #{@pid} already exists. " .
        "Make sure this daemon is not already running."
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
    #----- Fork off from the calling process -----#
    begin
      fork && exit!
      Process.setsid #----- make forked process session leader
      fork && exit!
    rescue => e
      STDERR.puts "Error: Failed to fork proeprly: \n\t: " +
        "(#{e.class}) #{e.message} "
      exit!
    end

    Dir::chdir(@workingdir) #----- chdir to working directory
    File::umask(0) #----- clear out file mode creation mask

    begin
      open(self.pidpath, "w") do |f|
        @pid = Process.pid
        f.puts @pid
      end
    rescue => e
      STDERR.puts "Error: Unable to open #{self.pidpath} for writing:\n\t" +
        "(#{e.class}) #{e.message}"
      exit!
    end

    STDIN.reopen("/dev/null", 'r')
    STDOUT.reopen("/dev/null", "w")
    STDERR.reopen("/dev/null", "w")
  end

#------------------------------------------------------------------------------#
  def stop
    begin
      open(self.pidpath, "r") do |f|
        @pid = f.read.to_i
      end
    rescue => e
#       STDERR.puts "Error: Unable to open #{self.pidpath} for reading:\n\t" +
#         "(#{e.class}) #{e.message}"
    end

    unless @pid
      STDERR.puts "pidfile #{self.pidpath} does not exist. Daemon not running?\n"
      return # not an error in a restart
    end

    begin
      while true do
        Process.kill("TERM", self.pid)
        sleep(0.1)
      end
    rescue Errno::ESRCH
    rescue => e
      STDERR.puts "unable to terminate process: (#{e.class}) #{e.message}"
      exit!
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
      File.unlink(self.pidpath)
    rescue => e
      STDERR.puts "ERROR: Unable to unlink #{self.pidpath}: (#{e.class}) #{e.message}"
      exit
    end
  end

#------------------------------------------------------------------------------#
  def run
  end
end
