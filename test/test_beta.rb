require_relative "test.rb"

class BetaTest < Test

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
