class BasicDaemon
  attr_accessor :workingdir, :pidfile, :piddir
  attr_reader :pid

  VERSION = '0.1.1'

  DEFAULT_OPTIONS = {
    :pidfile => File.basename($PROGRAM_NAME, File.extname($PROGRAM_NAME)),
    :piddir => '/tmp',
    :workingdir => '/'
  }

  #----------------------------------------------------------------------------#
  def initialize(*args)
    opts = {}

    case
    when args.length == 0 then
    when args.length == 1 && args[0].class == Hash then
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

  #----------------------------------------------------------------------------#
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
      STDERR.puts "pidfile #{self.pidpath} with pid #{@pid} already exists. " +
        "Make sure this daemon is not already running."
      exit!
    end

    #----- Fork off from the calling process -----#
    begin
      fork do
        Process.setsid #----- make forked process session leader
        fork && exit!

        at_exit do
          delpid
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

        unless block_given?
          self.run
        else
          yield
        end
      end
    rescue => e
      STDERR.puts "Error: Failed to fork properly: \n\t: " +
        "(#{e.class}) #{e.message} "
      exit!
    end
  end
  
  #----------------------------------------------------------------------------#
  def stop
    begin
      @pid = open(self.pidpath, "r").read.to_i
    rescue Errno::EACCES => e
      STDERR.puts "Error: Unable to open #{self.pidpath} for reading:\n\t" +
        "(#{e.class}) #{e.message}"
      exit!
    rescue => e
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

  #----------------------------------------------------------------------------#
  def restart
    self.stop
    self.start
  end

  #----------------------------------------------------------------------------#
  def run
  end

  #----------------------------------------------------------------------------#
  def pid_exists?
    begin
      pid = open(self.pidpath, "r").read.to_i
    rescue Errno::EACCES => e
      STDERR.puts "Error: Unable to open #{self.pidpath} for reading:\n\t" +
        "(#{e.class}) #{e.message}"
      exit!
    rescue => e
      return false
    end

    begin
      Process.kill(0, pid)
      true
    rescue Errno::ESRCH # "PID is NOT running or is zombied
      false
#     rescue Errno::EPERM
#       puts "No permission to query #{pid}!";
#     rescue
#       puts "Unable to determine status for #{pid} : #{$!}"
    end
  end

  private

  #----------------------------------------------------------------------------#
  def delpid
    begin
      File.unlink(self.pidpath)
    rescue => e
      STDERR.puts "ERROR: Unable to unlink #{self.pidpath}:\n\t" +
        "(#{e.class}) #{e.message}"
      exit
    end
  end

end
