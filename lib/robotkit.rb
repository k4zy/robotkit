require "robotkit/version"
require "fileutils"
require "erb"

module Robotkit
  def self.exec
    sample_package_name = "com.kazy91.github.twitterkit.sample"
    library_package_name = "com.kazy91.github.twitterkit.lib"
    library_module = "library"
    sample_module = "sample"
    fixtures_dir = "fixtures"
    output_dir = "dst"

    # copy from fixtues dir to output dir
    FileUtils.mkdir(output_dir)
    Dir.foreach(fixtures_dir).reject{|it| it.start_with?(".")}.each do |item|
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
