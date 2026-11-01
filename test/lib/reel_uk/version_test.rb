require_relative '../../test_helper'

class ReelUk::VersionTest < Minitest::Test
  def test_version_is_defined
    refute_nil ReelUk::VERSION
  end
end
