require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test/lib"
  t.ruby_opts << "-rhelper"
  t.test_files = FileList["test/**/test_*.rb"]
end

namespace :rbs do
  Rake::TestTask.new(:test) do |t|
    t.libs << "test_sig"
    t.test_files = FileList["test_sig/test_*.rb"].exclude("test_sig/test_helper.rb")
  end

  desc "Update RBS comments"
  task :annotate do
    require "tmpdir"

    Dir.mktmpdir do |tmpdir|
      sh("rdoc --ri --output #{tmpdir}/doc --root=. lib")
      sh("rbs annotate --no-system --no-gems --no-site --no-home -d #{tmpdir}/doc sig")
    end
  end
end

task :default => :test
