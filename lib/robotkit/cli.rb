require 'robotkit'
require 'thor'
require "fileutils"
require "erb"

module Robotkit
  PROJECT_ROOT_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))
  class CLI < Thor
    desc "create :output_dir", "Create Android library project."
    option :package, required: true
    option :library_module
    option :sample_module
    option :fixtures_dir
    def create(output_dir)
      puts output_dir
      Robotkit.exec(options.merge({output_dir: output_dir}))
    end
  end

  def self.exec(params)
    fixtures_dir = params[:fixtures_dir] || File.join(PROJECT_ROOT_PATH, "fixtures")
    output_dir = params[:output_dir]
    library_package_name = params[:package]
    sample_package_name = "#{params[:package]}.sample"
    library_module = params[:library_module] || "library"
    sample_module = params[:sample_module] || "sample"

    # copy from fixtues dir to output dir
    FileUtils.mkdir(output_dir)
    Dir.foreach(fixtures_dir).reject{|it| it.start_with?(".") && it == ".gitignore"}.each do |item|
      FileUtils.rm("#{output_dir}/#{item}", {force: true})
      FileUtils.cp_r("#{fixtures_dir}/#{item}", "#{output_dir}/#{item}", {preserve: true, dereference_root: true})
    end

    # change sample module dir
    File.rename("#{output_dir}/{sample_module}", "#{output_dir}/#{sample_module}")
    # change lib module dir
    File.rename("#{output_dir}/{library_module}", "#{output_dir}/#{library_module}")

    # create lib package dir
    FileUtils.mkdir_p("#{output_dir}/#{library_module}/src/main/java/#{library_package_name.gsub('.','/')}")
    FileUtils.rm_rf("#{output_dir}/#{library_module}/src/main/java/{library_package}")

    # create sample package dir
    sample_package_src = "#{output_dir}/#{sample_module}/src/main/java/#{sample_package_name.gsub('.','/')}"
    FileUtils.mkdir_p(sample_package_src)
    sample_files = %w(MainActivity SampleApplication)
    sample_files.each do |file_name|
      File.open("#{sample_package_src}/#{file_name}.java", "w") do |file|
        result = ERB.new(File.open("#{output_dir}/#{sample_module}/src/main/java/{sample_package}/#{file_name}.java.erb").read).result(binding)
        file.write(result)
      end
    end
    FileUtils.rm_rf("#{output_dir}/#{sample_module}/src/main/java/{sample_package}")

    #eval erb
    Dir.glob("#{output_dir}/**/*").select{|it| it.end_with?("erb")}.each do |path|
      result = ERB.new(File.open(path).read).result(binding)
      File.open(path.sub(".erb", ""), "w") do |file|
        file.write(result)
      end
      File.delete(path)
    end

  end
end
