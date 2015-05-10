module Xcodeproj
  class Project
    def target_named(name)
      self.targets.each do |target|
        if target.name == name.to_s
          return target
        end
      end
      nil
    end
  end
end

module Xcodeproj::Project::Object
  class PBXNativeTarget
    def sources_build_phase()
      self.build_phases.each do |phase|
        if phase.kind_of?(Xcodeproj::Project::Object::PBXSourcesBuildPhase)
          return phase
        end
      end
      nil
    end
  end

  class PBXSourcesBuildPhase
    def include_filename?(pattern)
      filenames = self.file_display_names
      if filenames.length == 0 and pattern
        return false
      end
      filenames.each do |filename|
        if not filename.match pattern
          return false
        end
      end
      return true
    end
  end
end
