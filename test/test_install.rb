require_relative "test.rb"

class InstallTest < Test

  def test_install_github
    seedfile %{
      github "devxoul/JLToast", "1.2.2", :files => "JLToast/*.{h,swift}"
    }
    @seed.install

    assert\
      File.exists?(File.join(@seeds_dirname, "JLToast")),
      "Directory Seeds/JLToast not exists."
  end


  def test_raise_invalid_github_reponame
    seedfile %{
      github "JLToast", "1.2.2"
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

end
