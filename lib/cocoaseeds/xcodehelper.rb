module Xcodeproj

  class Project

    def new_with_uuid(klass, uuid)
      if klass.is_a?(String)
        klass = Object.const_get(klass)
      end
      object = klass.new(self, uuid)
      object.initialize_defaults
      object
    end

    def new_group_with_uuid(name, uuid, path = nil, source_tree = :group)
      main_group.new_group_with_uuid(name, uuid, path, source_tree)
    end

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

  class PBXGroup
    def new_group_with_uuid(name, uuid, path = nil, source_tree = :group)
      group = project.new_with_uuid(PBXGroup, uuid)
      children << group
      group.name = name
      group.set_source_tree(source_tree)
      group.set_path(path)
      group
    end

    def new_reference_with_uuid(path, uuid, source_tree = :group)
      # customize `FileReferencesFactory.new_file_reference`
      path = Pathname.new(path)
      ref = self.project.new_with_uuid(PBXFileReference, uuid)
      self.children << ref
      GroupableHelper.set_path_with_source_tree(ref, path, source_tree)
      ref.set_last_known_file_type

      # customize `FileReferencesFactory.configure_defaults_for_file_reference`
      if ref.path.include?('/')
        ref.name = ref.path.split('/').last
      end
      if File.extname(ref.path).downcase == '.framework'
        ref.include_in_index = nil
      end

      ref
    end
    alias_method :new_file_with_uuid, :new_reference_with_uuid
  end

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
    def add_file_reference_with_uuid(file_ref, uuid, avoid_duplicates = false)
      if avoid_duplicates && existing = build_file(file_ref)
        existing
      else
        build_file = project.new_with_uuid(PBXBuildFile, uuid)
        build_file.file_ref = file_ref
        files << build_file
        build_file
      end
    end

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
