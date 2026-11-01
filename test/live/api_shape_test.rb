require_relative 'live_helper'

# The home page, a venue's pages and one film's showtimes on Reel's
# WordPress website, and a venue on the old A1Web website: seven requests.
class LiveApiShapeTest < Minitest::Test
  include ApiShapes

  CHORLEY = 'https://reel-cinemas.co.uk/chorley'.freeze
  HULL = 'https://reelcinemas.co.uk/hull'.freeze

  def test_wordpress_pages_are_readable
    website = ReelUk::Internal::Website.new

    assert_home_shape(website.home)
    venue = website.venue(CHORLEY)
    assert_venue_shape(venue)
    whats_on = website.whats_on(CHORLEY)
    assert_whats_on_shape(whats_on)
    assert_coming_soon_shape(website.coming_soon(CHORLEY))

    film_id = whats_on[ReelUk::Internal::Parser::WhatsOn::FILM, 1]
    assert_showtimes_shape(website.showtimes(film_id, venue[ReelUk::Internal::Listings::LOCATION, 1]))
  end

  def test_a1web_pages_are_readable
    assert_a1web_whats_on_shape(ReelUk::Cinema.a1web_client.whats_on(HULL))
  end
end
