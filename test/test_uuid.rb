require_relative "test.rb"

class UUIDTest < Test

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

end
