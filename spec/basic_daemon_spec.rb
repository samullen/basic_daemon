require File.join(File.dirname(__FILE__), '..', 'lib','basic_daemon')

describe BasicDaemon, "with default construction" do
  it "should default pidfile to #{File.basename($PROGRAM_NAME)}" do
    d = BasicDaemon.new
    d.pidfile.should == File.basename($PROGRAM_NAME)
  end

  it "should default piddir to /tmp" do
    d = BasicDaemon.new
    d.piddir.should == "/tmp"
  end

  it "should default workingdir to /" do
    d = BasicDaemon.new
    d.workingdir.should == "/"
  end
end

describe BasicDaemon, "with specified construction" do
  it "should set piddir to /var/lock" do
    d = BasicDaemon.new({:pidfile => 'foo', :piddir => '/var/lock', :workingdir => '/var/lock'})
    d.pidfile.should == 'foo'
  end

  it "should set pidfile to foo" do
    d = BasicDaemon.new({:pidfile => 'foo', :piddir => '/var/lock', :workingdir => '/var/lock'})
    d.pidfile.should == 'foo'
  end

  it "should set pidpath to /var/lock/foo" do
    d = BasicDaemon.new({:pidfile => 'foo', :piddir => '/var/lock', :workingdir => '/var/lock'})
    d.pidpath.should == '/var/lock/foo'
  end

  it "should set workingdir to /var/lock" do
    d = BasicDaemon.new({:pidfile => 'foo', :piddir => '/var/lock', :workingdir => '/var/lock'})
    d.workingdir.should == '/var/lock'
  end
end

describe BasicDaemon, "getting attributes updated" do
  it "should set pidfile to bar.txt after initially set to foo.txt" do
    d = BasicDaemon.new({:pidfile => "foo.txt"})
    d.pidfile.should == 'foo.txt'
    d.pidfile = 'bar.txt'
    d.pidfile.should == 'bar.txt'
    d.pidpath.should == '/tmp/bar.txt'
  end
end

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

