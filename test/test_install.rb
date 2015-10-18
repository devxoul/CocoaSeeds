require_relative "test.rb"

class InstallTest < Test

  def test_github_version
    seedfile %{
      github "devxoul/JLToast", "1.2.2", :files => "JLToast/*.{h,swift}"
    }
    @seed.install

    assert\
      File.exists?(File.join(@seeds_dirname, "JLToast")),
      "Directory Seeds/JLToast not exists."
  end


  def test_github_commit_1
    seedfile %{
      github "devxoul/SwipeBack", :commit => "534a677"
    }
    @seed.install

    dir = File.join(@seeds_dirname, "SwipeBack")

    assert\
      File.exists?(dir),
      "Directory Seeds/SwipeBack not exists."

    refute\
      File.exists?(File.join(dir, "SwipeBack/SwipeBack.h")),
      "File Seeds/SwipeBack/SwipeBack/SwipeBack.h should not exist."
  end


  def test_github_commit_2
    seedfile %{
      github "devxoul/SwipeBack", :commit => "90b256"
    }
    @seed.install

    dir = File.join(@seeds_dirname, "SwipeBack")

    assert\
      File.exists?(dir),
      "Directory Seeds/SwipeBack not exists."

    assert\
      File.exists?(File.join(dir, "SwipeBack/SwipeBack.h")),
      "File Seeds/SwipeBack/SwipeBack/SwipeBack.h does not exist."
  end


  def test_github_update
    path = File.join(@seeds_dirname, "SwiftyImage/SwiftyImage/SwiftyImage.h")

    seedfile %{
      github "devxoul/SwiftyImage", :commit => "af84dbd"
    }
    @seed.install
    refute File.exists?(path),
      "File Seeds/SwiftyImage/SwiftyImage/SwiftyImage.h should not exist."

    seedfile %{
      github "devxoul/SwiftyImage", :commit => "8b0c07a"
    }
    @seed.install
    assert File.exists?(path),
      "File Seeds/SwiftyImage/SwiftyImage/SwiftyImage.h does not exist."

    seedfile %{
      github "devxoul/SwiftyImage", :commit => "af84dbd"
    }
    @seed.install
    refute File.exists?(path),
      "File Seeds/SwiftyImage/SwiftyImage/SwiftyImage.h should not exist."
  end


  def test_raise_invalid_github_reponame
    seedfile %{
      github "JLToast", "1.2.2"
    }
    assert_raises Seeds::Exception do @seed.install end
  end


  def test_raise_github_both_tag_and_commit
    seedfile %{
      github "JLToast", "1.2.2", :commit => "83a1b50"
    }
    assert_raises Seeds::Exception do @seed.install end
  end

end


class InstallTest

  def test_install_bitbucket
    seedfile %{
      bitbucket "devxoul/JLToast", "1.2.2", :files => "JLToast/*.{h,swift}"
    }
    @seed.install

    assert\
      File.exists?(File.join(@seeds_dirname, "JLToast")),
      "Directory Seeds/JLToast not exists."
  end


  def test_raise_invalid_bitbucket_reponame
    seedfile %{
      bitbucket "JLToast", "1.2.2"
    }
    assert_raises Seeds::Exception do @seed.install end
  end


  def test_raise_bitbucket_both_tag_and_commit
    seedfile %{
      bitbucket "JLToast", "1.2.2", :commit => "83a1b50"
    }
    assert_raises Seeds::Exception do @seed.install end
  end

end
