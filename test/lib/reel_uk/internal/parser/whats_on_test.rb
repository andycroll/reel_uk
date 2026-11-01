require_relative '../../../../test_helper'

class ReelUk::Internal::Parser::WhatsOnTest < Minitest::Test
  include FixturesHelper

  def setup
    @parser = ReelUk::Internal::Parser::WhatsOn.new(website_fixture('whatson-chorley.html'), venue_url: WebsiteStubs::CHORLEY)
  end

  def test_films_by_jacro_id
    assert_equal 'The Hunger Games: Sunrise on the Reaping', @parser.films['3758']
    assert_equal 7, @parser.films.size
  end

  def test_each_showtime_once
    showings = @parser.showings

    assert_equal 19, showings.size
    assert_equal showings.map(&:booking_url).uniq, showings.map(&:booking_url)
  end

  def test_showtimes_carry_date_time_and_label
    showing = @parser.showings.first

    assert_equal 'Forgotten Island', showing.title
    assert_equal Date.new(2026, 11, 1), showing.date
    assert_equal Time.utc(2026, 11, 1, 10, 0), showing.starting_at
    assert_equal ['Movie Madness'], showing.tags
    assert_equal "#{WebsiteStubs::CHORLEY}/booknow/34266/", showing.booking_url
  end

  def test_blocks_without_a_film_are_skipped
    html = '<div class="nowshowing_film_box_outer nowshowingslider_20261101"><p>Nothing</p>'

    assert_empty ReelUk::Internal::Parser::WhatsOn.new(html, venue_url: WebsiteStubs::CHORLEY).showings
  end
end
