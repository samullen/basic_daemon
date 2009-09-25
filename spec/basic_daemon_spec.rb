require 'ftools'

require File.join(File.dirname(__FILE__), '..', 'lib','basic_daemon')

#------------------------------------------------------------------------------#
describe BasicDaemon, "with default construction" do
  before(:all) do
    @daemon = BasicDaemon.new
  end

  it "should default pidfile to #{File.basename($PROGRAM_NAME)}" do
    @daemon.pidfile.should == File.basename($PROGRAM_NAME)
  end

  it "should default piddir to /tmp" do
    @daemon.piddir.should == "/tmp"
  end

  it "should default workingdir to /" do
    @daemon.workingdir.should == "/"
  end
end

#------------------------------------------------------------------------------#
describe BasicDaemon, "with specified construction" do
  before(:all) do
    @daemon = BasicDaemon.new({:pidfile => 'foo', :piddir => '/var/lock', :workingdir => '/var/lock'})
  end

  it "should set piddir to /var/lock" do
    @daemon.pidfile.should == 'foo'
  end

  it "should set pidfile to foo" do
    @daemon.pidfile.should == 'foo'
  end

  it "should set pidpath to /var/lock/foo" do
    @daemon.pidpath.should == '/var/lock/foo'
  end

  it "should set workingdir to /var/lock" do
    @daemon.workingdir.should == '/var/lock'
  end
end

#------------------------------------------------------------------------------#
describe BasicDaemon, "getting attributes updated" do
  it "should set pidfile to bar.txt after initially set to foo.txt" do
    d = BasicDaemon.new({:pidfile => "foo.txt"})
    d.pidfile.should == 'foo.txt'
    d.pidfile = 'bar.txt'
    d.pidfile.should == 'bar.txt'
    d.pidpath.should == '/tmp/bar.txt'
  end
end

#------------------------------------------------------------------------------#
describe BasicDaemon, "running generically subclassed (OO)" do
  before(:each) do
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
    @mydaemon = MyDaemon.new
  end

  it "should create a pidfile containing the PID of the process at 'start' and remove at 'stop'" do
    @mydaemon.start
    sleep 1 #----- give child proc time to create file
    File.exists?(@mydaemon.pidpath).should == true
    File.open(@mydaemon.pidpath, 'r').read.should =~ /^\d+$/
    @mydaemon.stop
    File.exists?(@mydaemon.pidpath).should_not == true
    @mydaemon.pid_exists?.should_not == true
  end

  it "should remove the pidfile upon TERMination" do
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

    File.exists?(@mydaemon.pidpath).should_not == true
  end

  it "should put the process into the background" do
    @mydaemon.start
    sleep 1 #----- give child proc time to create file
    @mydaemon.pid_exists?.should == true
    @mydaemon.stop
    @mydaemon.pid_exists?.should_not == true
  end
end

#------------------------------------------------------------------------------#
# describe BasicDaemon, "running generically as a block (functional)" do
#   before(:each) do
#     @mydaemon = BasicDaemon.new
# 
#     @process = Proc.new {
#       foo = open("/tmp/out", "w")
# 
#       i = 1
# 
#       while true do
#         foo.puts "loop: #{i}"
#         foo.flush
#         sleep 2
# 
#         i += 1
#       end
#     }
#   end
# 
#   it "should create a pidfile containing the PID of the process at 'start' and remove at 'stop'" do
#     @mydaemon.start 
#     sleep 1 #----- give child proc time to create file
#     File.exists?(@mydaemon.pidpath).should == true
#     File.open(@mydaemon.pidpath, 'r').read.should =~ /^\d+$/
#     @mydaemon.stop
#     File.exists?(@mydaemon.pidpath).should_not == true
#     @mydaemon.pid_exists?.should_not == true
#   end
# 
#   it "should remove the pidfile upon TERMination" do
#     @mydaemon.start
#     sleep 1 #----- give child proc time to create file
#     pid = File.open(@mydaemon.pidpath, 'r').read.to_i
# 
#     begin
#       while true do
#         Process.kill("TERM", pid)
#         sleep(0.1)
#       end
#     rescue Errno::ESRCH
#     end
# 
#     File.exists?(@mydaemon.pidpath).should_not == true
#   end
# 
#   it "should put the process into the background" do
#     @mydaemon.start
#     sleep 1 #----- give child proc time to create file
#     @mydaemon.pid_exists?.should == true
#     @mydaemon.stop
#     @mydaemon.pid_exists?.should_not == true
#   end
# end

# def test_pidfile_creation_deletion
#   pid = nil
# 
#   d = BasicDaemon.new
#   d2 = BasicDaemon.new
#   d.start
# 
#   #----- testing creation of pid file -----#
#   assert File.exists?("/tmp/basicdaemon_test")
# 
#   open("/tmp/basicdaemon_test", "r") do |f|
#     pid = f.read.to_i
#   end
#   assert_equal d.pid, pid
# 
# #   d2.stop
# 
# #   flunk File.exists?("/tmp/basicdaemon_test")
# end

