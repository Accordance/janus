namespace :docker do
  desc 'Create Docker file'
  task create: :prepare do
    @app_version = Application::VERSION
    @app_name = Application::NAME
    @environment = ENV['RACK_ENV'] || 'production'
    template = File.read('docker/Dockerfile.erb')
    renderer = ERB.new(template)
    result = renderer.result
    File.write("#{PACKAGE_DIR}/Dockerfile", result)
  end

  desc 'Prepare build environment'
  task :prepare do
    File.open('BUILD_VARIABLES', 'w') do |f|
      f.puts("BUILD_VERSION=#{Application::VERSION}")
      f.puts("IMAGE_NAME=#{Application::NAME}")
      f.puts("IMAGE_TAG=#{image_tag}")
    end
  end

  def image_tag
    "docker/#{Application::NAME}:#{Application::VERSION}"
  end
end
