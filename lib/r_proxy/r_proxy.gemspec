# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "r_proxy"
  s.summary = "Insert RProxy summary."
  s.description = "Insert RProxy description."
  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.version = "0.0.1"
  s.add_dependency "nokogiri"
#  s.add_dependency "async-rack"
  s.add_dependency "async_sinatra"
  s.add_dependency "typhoeus"
  s.add_dependency "ezcrypto"
end
