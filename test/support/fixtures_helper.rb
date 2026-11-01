# Read fixtures from disk: pages captured from reel-cinemas.co.uk and
# reelcinemas.co.uk, trimmed to the parts the gem reads and to a few films
# on a few dates. They follow the shape in api_shapes.rb.
module FixturesHelper
  private

  def website_fixture(name)
    read_fixture("website/#{name}")
  end

  def read_fixture(filepath)
    File.read(File.expand_path("../../fixtures/#{filepath}", __FILE__))
  end
end
