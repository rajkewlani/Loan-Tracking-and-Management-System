namespace :test do
  Rake::TestTask.new(:rack => "db:test:prepare") do |t|
    t.libs << "test"
    t.pattern = "test/rack/**/*_test.rb"
    t.verbose = true
  end
  Rake::Task["test:rack"].comment = "Run the Rack::Test tests in test/rack"
end

task :test do
  Rake::Task["test:rack"].invoke
end