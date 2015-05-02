namespace :build do
  require_relative '../../lib/version'
  require 'rake/packagetask'
  require 'bump'

  PACKAGE_DIR = 'pkg'

  package_task = Rake::PackageTask.new(Application::NAME, Application::VERSION) do |p|
    p.package_dir = PACKAGE_DIR
    p.need_tar_gz = true
    p.package_files.include('server/**/*')
    p.package_files.include('daemons/**/*')
    p.package_files.include('config/**/*')
    p.package_files.include('lib/version.rb')
    p.package_files.include('Gemfile*')
    p.package_files.include('.ruby-version')
    p.package_files.include('.ruby-gemset')
    p.package_files.include('*.prod')
    p.package_files.include('config.ru')
  end

  task :bundle_vendor_gems do
    # sh 'bundle package'
    # vendor_files = FileList.new('vendor/**/**')
    # Have to add these files to the package_task file list
    # package_task.package_files = package_task.package_files + vendor_files
  end

  file package_task.package_dir_path => :bundle_vendor_gems

  CLEAN.include('vendor/**/*')

  desc "The current #{Application::NAME} version"
  task :version do
    puts Application::VERSION
  end

  desc 'Build and version releasable artifact'
  task committed_version: [:on_commit, :bump_version]

  desc 'Run specs and package releasable artifact'
  task on_commit: [:clean, 'spec:unit', 'spec:integration', :rubocop, :releasable_artifact]

  desc 'Build releasable artifact'
  task releasable_artifact: [:clobber_package, :clean_package, :prepare_artifact]

  desc 'Prepare artifact for Artifactory'
  task prepare_artifact: ['docker:create'] do
    rm_rf "#{PACKAGE_DIR}/#{Application::NAME}-#{Application::VERSION}"
    mkdir "#{PACKAGE_DIR}/#{Application::VERSION}"
    artifact = "#{Application::NAME}-#{Application::VERSION}.tar.gz"
    mv "#{PACKAGE_DIR}/#{artifact}", "#{PACKAGE_DIR}/#{Application::VERSION}/#{artifact}"
  end

  desc 'Bump the current version'
  task :bump_version do
    Bump::Bump.run('patch', commit: true, bundle: false, tag: true)
  end

  require 'rubocop/rake_task'
  if defined? RuboCop
    RuboCop::RakeTask.new
    task clean_package: [:rubocop, :package]
  else
    task clean_package: :package
  end
end
