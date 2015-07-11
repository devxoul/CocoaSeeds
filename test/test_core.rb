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
    project.new_target(:test, "TestProjTests", :ios)
    project.save

    # cocoaseeds
    @seed = Seeds::Core.new(@project_dirname)
    @seed.mute = true
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

  def seedfile(content)
    path = File.join(@project_dirname, "Seedfile")
    content = content ? content.strip.sub(/^\s+/, '') : ''
    File.write(path, content)
  end

  def test_raise_no_project
    FileUtils.rm_rf(@project_dirname)
    assert_raises Seeds::Exception do @seed.install end
  end

  def test_raise_no_seedfile
    assert_raises Seeds::Exception do @seed.install end
  end

  def test_raise_invalid_target
    seedfile %{
      target :InvalidTargetName do
        github "devxoul/JLToast", "1.2.2"
      end
    }
    assert_raises Seeds::Exception do @seed.install end
  end

  def test_raise_invalid_github_reponame
    seedfile %{
      github "JLToast", "1.2.2"
    }
    assert_raises Seeds::Exception do @seed.install end
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

    self.project.targets.each do |target|
      phase = target.sources_build_phase
      assert phase.files.length > 0
      phase.file_display_names.each do |filename|
        assert_match /.*\.(h|swift)/, filename
      end
    end
  end

  def test_install_multiple_files
    seedfile %{
      github "devxoul/JLToast", "1.2.2",
             :files => ["JLToast/JLToast.h", "JLToast/JLToast.swift"]
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

    self.project.targets.each do |target|
      phase = target.sources_build_phase
      assert phase.files.length > 0
      phase.file_display_names.each do |filename|
        assert_match /.*\.(h|swift)/, filename
      end
    end
  end

  def test_install_target
    seedfile %{
      target :TestProjTests do
        github "devxoul/JLToast", "1.2.2", :files => "JLToast/*.{h,swift}"
      end
    }
    @seed.install

    refute self.phase(:TestProj).include_filename?(/.*\.(h|swift)/)
    assert self.phase(:TestProjTests).include_filename?(/.*\.(h|swift)/)
  end

  def test_install_separated_target
    seedfile %{
      target :TestProj do
        github "devxoul/JLToast", "1.2.2", :files => "JLToast/*.{h,swift}"
      end

      target :TestProjTests do
        github "devxoul/SwipeBack", "1.0.4", :files => "SwipeBack/*.{h,m}"
      end
    }
    @seed.install

    assert self.phase(:TestProj).include_filename?(/JLToast.*\.(h|swift)/)
    refute self.phase(:TestProj).include_filename?(/.*SwipeBack\.(h|m)/)
    assert self.phase(:TestProjTests).include_filename?(/.*SwipeBack\.(h|m)/)
    refute self.phase(:TestProjTests).include_filename?(/JLToast.*\.(h|swift)/)
  end

  def test_install_common_before_separated_target
    seedfile %{
      github "devxoul/JLToast", "1.2.2", :files => "JLToast/*.{h,swift}"

      target :TestProjTests do
        github "devxoul/SwipeBack", "1.0.4", :files => "SwipeBack/*.{h,m}"
      end
    }
    @seed.install

    assert\
      self.phase(:TestProj).include_filename?(/JLToast.*\.(h|swift)/),
      "TestProj should have JLToast files."
    refute\
      self.phase(:TestProj).include_filename?(/.*SwipeBack\.(h|m)/),
      "TestProj shouldn't have SwipeBack files."

    assert\
      self.phase(:TestProjTests).include_filename?(/.*SwipeBack\.(h|m)/),
      "TestProjTests should have SwipeBack files."
    assert\
      self.phase(:TestProjTests).include_filename?(/JLToast.*\.(h|swift)/),
      "TestProjTests should have JLToast files."
  end

  def test_install_common_after_separated_target
    seedfile %{
      target :TestProjTests do
        github "devxoul/SwipeBack", "1.0.4", :files => "SwipeBack/*.{h,m}"
      end

      github "devxoul/JLToast", "1.2.2", :files => "JLToast/*.{h,swift}"
    }
    @seed.install

    assert\
      self.phase(:TestProj).include_filename?(/JLToast.*\.(h|swift)/),
      "TestProj should have JLToast files."
    refute\
      self.phase(:TestProj).include_filename?(/.*SwipeBack\.(h|m)/),
      "TestProj shouldn't have SwipeBack files."

    assert\
      self.phase(:TestProjTests).include_filename?(/.*SwipeBack\.(h|m)/),
      "TestProjTests should have SwipeBack files."
    assert\
      self.phase(:TestProjTests).include_filename?(/JLToast.*\.(h|swift)/),
      "TestProjTests should have JLToast files."
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

  def test_uuid_length
    seedfile %{
      github "devxoul/JLToast", "1.2.2", :files => "JLToast/*.{h,swift}"
    }
    @seed.install

    uuid = self.project["Seeds"]["JLToast"].uuid

    assert uuid.length == 24, "UUID's should be 24 characters long"
  end

  def test_uuid_preserve
    seedfile %{
      github "devxoul/JLToast", "1.2.2", :files => "JLToast/*.{h,swift}"
    }
    @seed.install

    uuids_before = []
    uuids_before << self.project["Seeds"]["JLToast"].uuid
    self.project["Seeds"]["JLToast"].files.each do |f|
      uuids_before << f.uuid
    end

    seedfile nil
    @seed.install

    seedfile %{
      github "devxoul/JLToast", "1.2.2", :files => "JLToast/*.{h,swift}"
    }
    @seed.install

    uuids_after = []
    uuids_after << self.project["Seeds"]["JLToast"].uuid
    self.project["Seeds"]["JLToast"].files.each do |f|
      uuids_after << f.uuid
    end

    assert_equal uuids_before, uuids_after
  end

  def test_swift_seedname_prefix
    seedfile %{
      swift_seedname_prefix!
      github "devxoul/JLToast", "1.2.2", :files => "JLToast/*.{h,swift}"
    }
    @seed.install

    self.project["Seeds"]["JLToast"].files.each do |file|
      assert_match /(.*\.h|JLToast_.*\.swift)/, file.name
    end

    self.project.targets.each do |target|
      phase = target.sources_build_phase
      assert phase.files.length > 0
      phase.file_display_names.each do |filename|
        assert_match /(.*\.h|JLToast_.*\.swift)/, filename
      end
    end
  end

end
