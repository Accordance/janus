require 'rspec/core'
require 'rspec/core/rake_task'
require_relative '../../spec/integration/data/data_config'

namespace :spec do
  CLOBBER.include 'out/*'

  desc 'Run specs'
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.verbose = true
    t.pattern = ['spec/{requests}/**/*_spec.rb']
    t.rspec_opts = spec_output 'spec_unit.xml'
  end

  desc 'Run integration specs'
  RSpec::Core::RakeTask.new(:integration_spec) do |t|
    t.verbose = true
    t.pattern = ['spec/{integration}/**/*_spec.rb']
    t.rspec_opts = spec_output 'spec_integration.xml'
  end

  def spec_output(filename)
    "--format documentation --format RspecJunitFormatter --out out/#{filename}"
  end

  task :ensure_no_mongo do
    pid = `ps aux | grep mongod[b] | awk '{ print $2 }'`
    Process.kill 'INT', pid.to_i unless pid == ''
  end

  task :start_mongo do
    mkdir_p DataConfig::DB_DIR
    mkdir_p DataConfig::LOG_DIR
    puts 'Starting Mongo'
    sh "mongod --fork --dbpath #{DataConfig::DB_DIR} --pidfilepath #{Dir.pwd}/#{DataConfig::LOG_DIR}/mongo.pid --smallfiles --logpath #{DataConfig::LOG_DIR}/mongo.log"
  end

  task :stop_mongo do
    begin
      puts 'Stopping Mongo'
      sh "kill `cat #{DataConfig::LOG_DIR}/mongo.pid`"
    rescue
      p 'Unable to kill MongoDB'
    end
  end

  task all: [:unit, :integration]

  task integration: [:clean, :ensure_no_mongo, :start_mongo, :integration_spec, :stop_mongo]

  CLEAN.include "#{DataConfig::DB_DIR}/*"
  CLEAN.include "#{DataConfig::LOG_DIR}/*"
end
