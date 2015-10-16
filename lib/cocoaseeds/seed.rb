module Seeds
  class Seed

    # @return [String] the name of the seed
    #
    attr_accessor :name

    # @return [String] the version of the seed
    #
    attr_accessor :version

    # @return [String] the commit hash of the seed
    #
    attr_accessor :commit

    # @return [String] the url of the seed
    #
    attr_accessor :url

    # @return [Array<String>] the source file patterns of the seed
    #
    attr_accessor :files

    # @return [String] lockfile-formatted string
    #
    # @example JLToast (1.2.2)
    #
    def to_s
      "#{self.name} (#{self.version})"
    end

    class GitHub < Seed
      def to_s
        "#{self.name} (#{self.version})"
      end
    end

    class BitBucket < Seed
      def to_s
        "#{self.name} (#{self.version})"
      end
    end
  end
end
