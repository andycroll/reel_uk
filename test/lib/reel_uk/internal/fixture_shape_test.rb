require_relative '../../../test_helper'

class FixtureShapeTest < Minitest::Test
  include ApiShapes
  include FixturesHelper

  def test_home_page_fixture_matches_shape
    assert_home_shape(website_fixture('home.html'))
  end

  def test_venue_page_fixture_matches_shape
    assert_venue_shape(website_fixture('venue-chorley.html'))
  end

  def test_whats_on_fixture_matches_shape
    assert_whats_on_shape(website_fixture('whatson-chorley.html'))
  end

  def test_coming_soon_fixture_matches_shape
    assert_coming_soon_shape(website_fixture('comingsoon-chorley.html'))
  end

  def test_showtimes_fixtures_match_shape
    WebsiteStubs::SCHEDULED_FILMS.each do |film_id|
      assert_showtimes_shape(JSON.parse(website_fixture("showtimes-#{film_id}.json")).fetch('html'))
    end
  end

  def test_a1web_whats_on_fixture_matches_shape
    assert_a1web_whats_on_shape(website_fixture('whatson-hull.html'))
  end
end
