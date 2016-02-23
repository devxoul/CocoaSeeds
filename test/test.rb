require "minitest/autorun"

require_relative "../lib/cocoaseeds"

class Test < Minitest::Test

  def setup
    pwd = File.expand_path(File.dirname(__FILE__))

    @project_dirname = File.join(pwd, "TestProj")
    @seeds_dirname = File.join(@project_dirname, "Seeds")

    # clean
    FileUtils.rm_rf(@project_dirname)

    # create a new project
    @project_filename = File.join(@project_dirname, "TestProj.xcodeproj")
    project = Xcodeproj::Project.new(@project_filename)
    project.new_target(:application, "TestProj", :ios)
    project.new_target(:test, "TestProjTests", :ios)
    project.save

    # cocoaseeds
    @seed = Seeds::Core.new(@project_dirname)
    @seed.mute = true
  end


  # Deletes existing project and creates new one in a subdirectory "MyApp".
  def subdirectory_project
    FileUtils.rm_rf(@project_filename)
    new_dir = File.join(@project_dirname, "MyApp")
    FileUtils.mkdir(new_dir)
    @project_filename = File.join(new_dir, "TestProj.xcodeproj")
    project = Xcodeproj::Project.new(@project_filename)
    project.new_target(:application, "TestProj", :ios)
    project.new_target(:test, "TestProjTests", :ios)
    project.save
  end


  def teardown
    FileUtils.rm_rf(@project_dirname)
  end


  def project
    Xcodeproj::Project.open(@project_filename)
  end


  def phase(target_name)
    self.project.target_named(target_name).sources_build_phase
  end


  def resource_phase(target_name)
    self.project.target_named(target_name).resources_build_phase
  end


  def seedfile(content)
    path = File.join(@project_dirname, "Seedfile")
    content = content ? content.strip.sub(/^\s+/, '') : ''
    File.write(path, content)
  end

end
