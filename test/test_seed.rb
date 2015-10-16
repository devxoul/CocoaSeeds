require_relative "test.rb"

class SeedTest < Test

  def test_github_version
    seedfile %{
      github "devxoul/JLToast", "1.3.2"
    }
    @seed.prepare_requirements
    @seed.execute_seedfile
    s = @seed.seeds["JLToast"]
    assert_equal s.name, "JLToast"
    assert_equal s.version, "1.3.2"
    assert_equal s.url, "https://github.com/devxoul/JLToast"
  end


  def test_github_commit
    seedfile %{
      github "devxoul/JLToast", :commit => "83a1b50153ed26f0ae0e90d65"
    }
    @seed.prepare_requirements
    @seed.execute_seedfile
    s = @seed.seeds["JLToast"]
    assert_equal s.name, "JLToast"
    assert_nil s.version
    assert_equal s.commit, "83a1b50"
    assert_equal s.url, "https://github.com/devxoul/JLToast"
  end


  def test_github_version_and_files
    seedfile %{
      github "devxoul/JLToast", "1.3.2", :files => "JLToast/*.{h,swift}"
    }
    @seed.prepare_requirements
    @seed.execute_seedfile
    s = @seed.seeds["JLToast"]
    assert_equal s.name, "JLToast"
    assert_equal s.version, "1.3.2"
    assert_equal s.url, "https://github.com/devxoul/JLToast"
    assert_equal s.files, ["JLToast/*.{h,swift}"]
  end


  def test_github_version_and_files_array
    seedfile %{
      github "devxoul/JLToast", "1.3.2",
        :files => ["JLToast/JLToast.h", "JLToast/JLToast.swift"]
    }
    @seed.prepare_requirements
    @seed.execute_seedfile
    s = @seed.seeds["JLToast"]
    assert_equal s.name, "JLToast"
    assert_equal s.version, "1.3.2"
    assert_equal s.url, "https://github.com/devxoul/JLToast"
    assert_equal s.files, ["JLToast/JLToast.h", "JLToast/JLToast.swift"]
  end


  def test_github_commit_and_files
    seedfile %{
      github "devxoul/JLToast",
        :commit => "83a1b50",
        :files => "JLToast/*.{h,swift}"
    }
    @seed.prepare_requirements
    @seed.execute_seedfile
    s = @seed.seeds["JLToast"]
    assert_equal s.name, "JLToast"
    assert_nil s.version
    assert_equal s.commit, "83a1b50"
    assert_equal s.url, "https://github.com/devxoul/JLToast"
    assert_equal s.files, ["JLToast/*.{h,swift}"]
  end

end


class SeedTest

  def test_bitbucket_version
    seedfile %{
      bitbucket "devxoul/JLToast", "1.3.2"
    }
    @seed.prepare_requirements
    @seed.execute_seedfile
    s = @seed.seeds["JLToast"]
    assert_equal s.name, "JLToast"
    assert_equal s.version, "1.3.2"
    assert_equal s.url, "https://bitbucket.org/devxoul/JLToast"
  end


  def test_bitbucket_commit
    seedfile %{
      github "devxoul/JLToast", :commit => "83a1b50"
    }
    @seed.prepare_requirements
    @seed.execute_seedfile
    s = @seed.seeds["JLToast"]
    assert_equal s.name, "JLToast"
    assert_nil s.version
    assert_equal s.commit, "83a1b50"
    assert_equal s.url, "https://github.com/devxoul/JLToast"
  end


  def test_bitbucket_version_and_files
    seedfile %{
      bitbucket "devxoul/JLToast", "1.3.2", :files => "JLToast/*.{h,swift}"
    }
    @seed.prepare_requirements
    @seed.execute_seedfile
    s = @seed.seeds["JLToast"]
    assert_equal s.name, "JLToast"
    assert_equal s.version, "1.3.2"
    assert_equal s.url, "https://bitbucket.org/devxoul/JLToast"
    assert_equal s.files, ["JLToast/*.{h,swift}"]
  end


  def test_bitbucket_version_and_files_array
    seedfile %{
      bitbucket "devxoul/JLToast", "1.3.2",
        :files => ["JLToast/JLToast.h", "JLToast/JLToast.swift"]
    }
    @seed.prepare_requirements
    @seed.execute_seedfile
    s = @seed.seeds["JLToast"]
    assert_equal s.name, "JLToast"
    assert_equal s.version, "1.3.2"
    assert_equal s.url, "https://bitbucket.org/devxoul/JLToast"
    assert_equal s.files, ["JLToast/JLToast.h", "JLToast/JLToast.swift"]
  end


  def test_bitbucket_commit_and_files
    seedfile %{
      github "devxoul/JLToast",
        :commit => "83a1b50",
        :files => "JLToast/*.{h,swift}"
    }
    @seed.prepare_requirements
    @seed.execute_seedfile
    s = @seed.seeds["JLToast"]
    assert_equal s.name, "JLToast"
    assert_nil s.version
    assert_equal s.commit, "83a1b50"
    assert_equal s.url, "https://github.com/devxoul/JLToast"
    assert_equal s.files, ["JLToast/*.{h,swift}"]
  end

end
