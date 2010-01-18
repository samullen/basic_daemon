require 'rake/testtask'
 
lib_dir = File.expand_path('lib')
test_dir = File.expand_path('test')

Rake::TestTask.new(:test) do |t|
  t.libs = [lib_dir, test_dir]
  t.pattern = 'test/**/*rb'
  t.verbose = true
end

task :default => [:test]
