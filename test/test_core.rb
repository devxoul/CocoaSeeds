require "minitest/autorun"

require_relative "../lib/cocoaseeds"

class CoreTest < Minitest::Test

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
    project.save

    # cocoaseeds
    @seed = Seeds::Core.new(@project_dirname)
  end

  def teardown
    FileUtils.rm_rf(@project_dirname)
  end

  def project
    Xcodeproj::Project.open(@project_filename)
  end

  def seedfile(content)
    path = File.join(@project_dirname, "Seedfile")
    content = content ? content.strip.sub(/^\s+/, '') : ''
    File.write(path, content)
  end

  def test_install
    seedfile %{
      github "devxoul/JLToast", "1.2.2", :files => "JLToast/*.{h,swift}"
    }
    @seed.install

    assert\
      File.exists?(File.join(@seeds_dirname, "JLToast")),
      "Directory Seeds/JLToast not exists."

    refute_nil\
      self.project["Seeds"]["JLToast"],
      "Group 'Seeds/JLToast' not exists in the project."

    self.project["Seeds"]["JLToast"].files.each do |file|
      assert_match /.*\.(h|swift)/, file.name
    end
  end

  def test_remove
    seedfile %{
      github "devxoul/JLToast", "1.2.2", :files => "JLToast/*.{h,swift}"
    }
    @seed.install

    seedfile nil
    @seed.install

    assert\
      !File.exists?(File.join(@seeds_dirname, "JLToast")),
      "Directory Seeds/JLToast exists."

    assert_nil\
      self.project["Seeds"]["JLToast"],
      "Group 'Seeds/JLToast' exists in the project."
  end

end
