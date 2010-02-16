class BasicDaemon
  attr_accessor :workingdir, :pidfile, :piddir, :process

  VERSION = '0.9.0'

  DEFAULT_OPTIONS = {
    :pidfile => File.basename($PROGRAM_NAME, File.extname($PROGRAM_NAME)),
    :piddir => '/tmp',
    :workingdir => '/'
  }

  # Instantiate a new BasicDaemon
  #
  # Takes an optional hash with the following symbol keys:
  # - :piddir = Directory to store the PID file in. Default is /tmp
  # - :pidfile = name of the file to store the PID in. default is the script 
  #   name sans extension.
  # - :workingdir = Directory to work from. Default is "/" and should probably 
  #   be left as such.
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
    @process    = nil
  end

  # Returns the fullpath to the file containing the process ID (PID)
  def pidpath
    File.join(@piddir, @pidfile)
  end

  # Returns the PID of the currently running daemon
  def pid
    return @pid unless @pid.nil?

    begin
      @pid = open(self.pidpath, 'r').read.to_i
    rescue Errno::EACCES => e
      STDERR.puts "Error: unable to open file #{self.pidpath} for reading:\n\t"+
        "(#{e.class}) #{e.message}"
      exit!
    rescue => e
    end

    @pid
  end

  # Starts the daemon by forking the supplied process either by block or by 
  # overridden run method.
  def start(&block)
    if pid
      STDERR.puts "pidfile #{self.pidpath} with pid #{@pid} already exists. " +
        "Make sure this daemon is not already running."
      exit!
    end

    if block_given?
      @process = block
    end

    #----- Fork off from the calling process -----#
    begin
      fork do
        Process.setsid #----- make forked process session leader
        fork && exit!

        at_exit do
          delpidfile
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

        unless @process.nil?
          @process.call
        else
          self.run
        end
      end
    rescue => e
      STDERR.puts "Error: Failed to fork properly: \n\t: " +
        "(#{e.class}) #{e.message}"
      exit!
    end
  end
  
  # stops the daemon. It does this by retrieving the process ID (PID) of the 
  # currently running process from the pidfile and killing it till it's dead.
  def stop
    unless self.pid
      STDERR.puts "pidfile #{self.pidpath} does not exist. Daemon not running?\n"
      return # not an error in a restart
    end

    begin
      while true do
        Process.kill("TERM", self.pid)
        sleep(0.1)
      end
    rescue Errno::ESRCH # gets here when there is no longer a process to kill
    rescue => e
      STDERR.puts "unable to terminate process: (#{e.class}) #{e.message}"
      exit!
    end
  end

  # restarts the daemon by first killing it and then restarting. 
  #
  # Warning: does not work if block is initially passed to start.
  def restart
    self.stop
    @pid = nil

    unless @process.nil?
      self.start
    else
      self.start &@process
    end
  end

  # Boolean. Does the current process exist? True or false.
  # Reads the PID from the pidfile and attempts to "kill 0" the process.
  # Success results in true; failure, false.
  def process_exists?
    begin
      Process.kill(0, self.pid)
      true
    rescue Errno::ESRCH, TypeError # "PID is NOT running or is zombied
      false
    rescue Errno::EPERM
      STDERR.puts "No permission to query #{pid}!";
    rescue => e
      STDERR.puts "(#{e.class}) #{e.message}:\n\t" << 
        "Unable to determine status for #{pid}."
    end
  end

  # run should be overridden if using BasicDaemon Object Orientedly. 
  # See examples.
  def run
  end

  private

  #----------------------------------------------------------------------------#
  def delpidfile
    begin
      File.unlink(self.pidpath)
    rescue => e
      STDERR.puts "ERROR: Unable to unlink #{self.pidpath}:\n\t" +
        "(#{e.class}) #{e.message}"
      exit
    end
  end
end
