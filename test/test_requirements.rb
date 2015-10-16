require_relative "test.rb"

class RequirementsTest < Test

  def test_raise_no_project
    FileUtils.rm_rf(@project_dirname)
    assert_raises Seeds::Exception do @seed.install end
  end


  def test_raise_no_seedfile
    assert_raises Seeds::Exception do @seed.install end
  end

end
