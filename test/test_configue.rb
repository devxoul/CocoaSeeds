require_relative "test.rb"

class CoreTest < Test

  def test_raise_invalid_target
    seedfile %{
      target :InvalidTargetName do
        github "devxoul/JLToast", "1.2.2"
      end
    }
    assert_raises Seeds::Exception do @seed.install end
  end


  def test_configure
    seedfile %{
      github "devxoul/JLToast", "1.2.2", :files => "JLToast/*.{h,swift}"
    }
    @seed.install

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


  def test_multiple_files
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


  def test_target
    seedfile %{
      target :TestProjTests do
        github "devxoul/JLToast", "1.2.2", :files => "JLToast/*.{h,swift}"
      end
    }
    @seed.install

    refute self.phase(:TestProj).include_filename?(/.*\.(h|swift)/)
    assert self.phase(:TestProjTests).include_filename?(/.*\.(h|swift)/)
  end


  def test_separated_target
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


  def test_common_before_separated_target
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


  def test_common_after_separated_target
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


  def test_exclude_files
    seedfile %{
      github "devxoul/JLToast", "1.2.2",
        :files => "JLToast/*.{h,swift}",
        :exclude_files => "JLToast/JLToast.swift"
    }
    @seed.install

    assert\
      !self.phase(:TestProj).include_filename?('JLToast.swift'),
      "TestProj should not have JLToast.swift"
    assert\
      !self.phase(:TestProjTests).include_filename?('JLToast.swift'),
      "TestProjTests should not have JLToast.swift"

    assert\
      self.phase(:TestProj).include_filename?('JLToastCenter.swift'),
      "TestProj should have JLToastCenter.swift"
    assert\
      self.phase(:TestProjTests).include_filename?('JLToastCenter.swift'),
      "TestProjTests should have JLToastCenter.swift"
  end


  def test_commit_exclude_files
    seedfile %{
      github "devxoul/JLToast",
        :commit => "908bca5",
        :files => "JLToast/*.{h,swift}",
        :exclude_files => "JLToast/JLToast.swift"
    }
    @seed.install

    assert\
      !self.phase(:TestProj).include_filename?('JLToast.swift'),
      "TestProj should not have JLToast.swift"
    assert\
      !self.phase(:TestProjTests).include_filename?('JLToast.swift'),
      "TestProjTests should not have JLToast.swift"

    assert\
      self.phase(:TestProj).include_filename?('JLToastCenter.swift'),
      "TestProj should have JLToastCenter.swift"
    assert\
      self.phase(:TestProjTests).include_filename?('JLToastCenter.swift'),
      "TestProjTests should have JLToastCenter.swift"
  end


  def test_resources
    seedfile %{
      github "SwiftyJSON/SwiftyJSON", "2.3.2",
        :files => "Source/*.{swift,h,plist}"
    }
    @seed.install

    assert\
      self.phase(:TestProj).include_filename?('SwiftyJSON.swift'),
      "TestProj build phase should have SwiftyJSON.swift"
    assert\
      !self.resource_phase(:TestProj).include_filename?('SwiftyJSON.swift')
      "TestProj resource phase should have SwiftyJSON.swift"

    assert\
      !self.phase(:TestProj).include_filename?('Info-iOS.plist'),
      "TestProj build phase should not have Info-iOS.plist"
    assert\
      self.resource_phase(:TestProj).include_filename?('Info-iOS.plist')
      "TestProj resource phase should have Info-iOS.plist"
  end

  def test_custom_git_source
    seedfile %{
      git "https://github.com/SwiftyJSON/SwiftyJSON.git", "2.3.2", :files => "Source/*.{swift,h,plist}"
    }
    @seed.install

    assert\
      self.phase(:TestProj).include_filename?('SwiftyJSON.swift'),
      "TestProj build phase should have SwiftyJSON.swift"
    assert\
      !self.resource_phase(:TestProj).include_filename?('SwiftyJSON.swift')
    "TestProj resource phase should have SwiftyJSON.swift"

    assert\
      !self.phase(:TestProj).include_filename?('Info-iOS.plist'),
      "TestProj build phase should not have Info-iOS.plist"
    assert\
      self.resource_phase(:TestProj).include_filename?('Info-iOS.plist')
    "TestProj resource phase should have Info-iOS.plist"

  end

  def test_local_source

    pwd = File.expand_path(File.dirname(__FILE__))
    new_dir = File.join(pwd, "TestDir")
    FileUtils.mkdir(new_dir)

    swift_file_path = File.join(new_dir, "a.swift")
    plist_file_path = File.join(new_dir, "a.plist")
    File.open(swift_file_path, "w+") { |file| file.write("") }
    File.open(plist_file_path, "w+") { |file| file.write("") }

    seedfile %{
      local "Test","./test/TestDir/", :files => "*.{swift,h,plist}"
    }

    @seed.install

    assert\
      self.phase(:TestProj).include_filename?('a.swift'),
      "TestProj build phase should have a.swift"
    assert\
      !self.resource_phase(:TestProj).include_filename?('a.swift'),
      "TestProj resource phase should not have a.swift"

    assert\
      !self.phase(:TestProj).include_filename?('a.plist'),
      "TestProj build phase should not have a.plist"
    assert\
      self.resource_phase(:TestProj).include_filename?('a.plist'),
    "TestProj resource phase should have a.plist"
    FileUtils.rm_rf new_dir




    assert_nil\
      self.project["Seeds"]["JLToast"],
      "Group 'Seeds/JLToast' exists in the project."
  end

end
