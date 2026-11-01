require_relative '../../../../test_helper'

class ReelUk::Internal::Parser::ComingSoonTest < Minitest::Test
  include FixturesHelper

  def test_films_with_showtimes_on_sale
    films = ReelUk::Internal::Parser::ComingSoon.new(website_fixture('comingsoon-chorley.html')).films

    assert_equal({ '3915' => 'RBO 2026-2027: The Nutcracker', '3760' => 'Avengers: Doomsday' }, films)
  end
end
