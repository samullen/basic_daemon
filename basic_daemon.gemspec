Gem::Specification.new do |spec|
  spec.name = "basic_daemon"
  spec.version = "0.1.4"
  spec.summary = "A simple ruby library for daemonizing processes"
  spec.description = "A simple ruby library for daemonizing processes"
  spec.email = "samullen@gmail.com"
  spec.authors = ["Samuel Mullen"]
  spec.homepage = "http://github.com/samullen/BasicDaemon"
  spec.test_files = [
    "test/oo_basic_daemon_test.rb",
    "test/functional_basic_daemon_test.rb",
    "test/basic_daemon_test.rb",
    "examples/functional.rb",
    "examples/objectoriented.rb"
  ]
  spec.files = [
    "History.txt",
    "License.txt",
    "README",
    "Rakefile",
    "TODO",
    "basic_daemon.gemspec",
    "examples/functional.rb",
    "examples/objectoriented.rb",
    "lib/basic_daemon.rb"
  ] + spec.test_files
end

