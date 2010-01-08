# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{basic_daemon}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Samuel Mullen"]
  s.date = %q{2010-01-08}
  s.description = %q{A simple ruby library for daemonizing processes}
  s.email = %q{samullen@gmail.com}
  s.extra_rdoc_files = [
    "README",
     "TODO"
  ]
  s.files = [
    "History.txt",
     "License.txt",
     "README",
     "Rakefile",
     "TODO",
     "basic_daemon.gemspec",
     "examples/functional.rb",
     "examples/objectoriented.rb",
     "lib/basic_daemon.rb",
     "test/basic_daemon_test.rb",
     "test/functional_basic_daemon_test.rb",
     "test/oo_basic_daemon_test.rb"
  ]
  s.homepage = %q{http://github.com/samullen/BasicDaemon}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A simple ruby library for daemonizing processes}
  s.test_files = [
    "test/oo_basic_daemon_test.rb",
     "test/functional_basic_daemon_test.rb",
     "test/basic_daemon_test.rb",
     "examples/functional.rb",
     "examples/objectoriented.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

