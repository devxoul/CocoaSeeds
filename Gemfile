source "https://rubygems.org"

# runtime dependencies from gemspec
gemspec = File.read("cocoaseeds.gemspec")
gemspec.scan(/(?<=s\.add_runtime_dependency ).*/).each do |dependency|
  eval "gem #{dependency}"
end
