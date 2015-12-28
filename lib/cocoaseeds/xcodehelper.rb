module Xcodeproj

  class Project

    # Creates a new object with given UUID.
    #
    # @param [String] uuid UUID of the object.
    #
    def new_with_uuid(klass, uuid)
      if klass.is_a?(String)
        klass = Object.const_get(klass)
      end
      object = klass.new(self, uuid)
      object.initialize_defaults
      object
    end

    # Creates a new group with given UUID.
    #
    # @param [String] uuid UUID of the object.
    #
    def new_group_with_uuid(name, uuid, path = nil, source_tree = :group)
      main_group.new_group_with_uuid(name, uuid, path, source_tree)
    end

    # @param [String] name The name of target.
    # @return the target with given name
    #
    def target_named(name)
      self.targets.each do |target|
        if target.name == name.to_s
          return target
        end
      end
      nil
    end

  end

  def self.uuid_with_name(name)
      Digest::MD5.hexdigest(name).upcase[0,24]
  end
end


module Xcodeproj::Project::Object

  class PBXGroup

    # Creates a new group with given UUID.
    #
    # @param [String] uuid UUID of the object.
    #
    def new_group_with_uuid(name, uuid, path = nil, source_tree = :group)
      group = project.new_with_uuid(PBXGroup, uuid)
      children << group
      group.name = name
      group.set_source_tree(source_tree)
      group.set_path(path)
      group
    end


    # Creates a file reference with given UUID.
    #
    # @param [String] uuid UUID of the object.
    #
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

    # @return 'Sources Build Phase' or `nil`
    #
    def sources_build_phase()
      self.build_phases.each do |phase|
        if phase.kind_of?(Xcodeproj::Project::Object::PBXSourcesBuildPhase)
          return phase
        end
      end
      nil
    end
  end

  class PBXLegacyTarget

    # @return 'Sources Build Phase' or `nil`
    #
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

    # Adds the file reference with given UUID.
    #
    # @param [String] uuid UUID of the object.
    #
    def add_file_reference_with_uuid(file_ref, uuid, avoid_duplicates = false)
      if avoid_duplicates && existing = build_file(file_ref)
        existing
      else
        build_file = project.new_with_uuid(PBXBuildFile, uuid)
        build_file.file_ref = file_ref
        files.insert(0, build_file)
        build_file
      end
    end

    # @return whether the file names match the pattern.
    # @param [Regexp] pattern The pattern of file name.
    #
    def include_filename?(pattern)
      self.file_display_names.each do |filename|
        return true if filename.match pattern
      end
      false
    end

  end
end
