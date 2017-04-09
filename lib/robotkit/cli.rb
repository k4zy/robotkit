require 'robotkit'
require 'tty-prompt'
require "fileutils"
require "erb"

module Robotkit
  PROJECT_ROOT_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))
  IGNORE_FILES = %w(. .. .DS_Store)
  class CLI
    def self.start
      options = {}
      prompt = TTY::Prompt.new(help_color: :cyan)
      options[:output_dir] = prompt.ask('What is library name?', default: 'SampleLibrary')
      options[:package_name] = prompt.ask('What is package name?', default: 'com.android.sample')
      options[:module_name] = prompt.ask('What is module name?', default: options[:output_dir].downcase)
      options[:min_sdk] = prompt.ask('Type min_sdk version', default: 16)
      options[:target_sdk] = prompt.ask('Type target_sdk version', default: 25)

      library_choices = %w(maven-gradle-plugin jack)
      options[:selected_library_options] = prompt.multi_select("Select library module options: ", library_choices)

      sample_choices = %w(jack rxjava1 rxjava2)
      options[:selected_sample_options] = prompt.multi_select("Select sample module options: ", sample_choices)

      puts options[:output_dir]
      Robotkit.exec(options)
    end
  end

  def self.exec(params)
    fixtures_dir = params[:fixtures_dir] || File.join(PROJECT_ROOT_PATH, "fixtures")
    output_dir = params[:output_dir]
    project_name = params[:output_dir]
    library_package_name = params[:package_name]
    sample_package_name = "#{params[:package_name]}.sample"
    library_module = params[:module_name] || "library"
    sample_module = params[:sample_module] || "sample"

    # copy from fixtues dir to output dir
    FileUtils.mkdir(output_dir)
    Dir.foreach(fixtures_dir).reject{|it| IGNORE_FILES.include?(it)}.each do |item|
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
    FileUtils.rm_rf("#{output_dir}/#{library_module}/{library_module}")

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
    FileUtils.rm_rf("#{output_dir}/#{sample_module}/{sample_module}")

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
