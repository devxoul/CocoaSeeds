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
        :exclude_files => "JLToast/JLToast.h"
    }
    @seed.install

    assert\
      !self.phase(:TestProj).include_filename?('JLToast.h'),
      "TestProj should not have JLToast.h"
    assert\
      !self.phase(:TestProjTests).include_filename?('JLToast.h'),
      "TestProjTests should not have JLToast.h"

    assert\
      self.phase(:TestProj).include_filename?('JLToast.swift'),
      "TestProj should have JLToast.swift"
    assert\
      self.phase(:TestProjTests).include_filename?('JLToast.swift'),
      "TestProjTests should have JLToast.swift"
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
