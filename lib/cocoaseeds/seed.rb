module CocoaSeed
  class Seed
    attr_accessor :name, :version, :url, :files

    def to_s
      "#{self.name} (#{self.version})"
    end

    class GitHub < Seed
      def to_s
        "#{self.name} (#{self.version}) #{files}"
      end
    end
  end
end
