require 'bundler/gem_tasks'

task :default => ["test"]

task :test do
  Rake::Task['test:unit'].execute
  Rake::Task['test:integration'].execute
end

namespace :test do
  desc "Run unit tests"
  task :unit do
    Dir["test/unit/*_test.rb"].each do |path|
      system "ruby -Ilib -Itest #{path}"
    end
  end

  desc "Run integration tests"
  task :integration do
    Dir["test/integration/*_test.rb"].each do |path|
      system "ruby -Ilib -Itest #{path}"
    end
  end
end
