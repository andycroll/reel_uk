require_relative '../../../../test_helper'

class ReelUk::Internal::Parser::ShowtimesTest < Minitest::Test
  include FixturesHelper

  def test_every_showtime_on_sale
    showings = parse('3758')

    assert(showings.all? { |showing| showing.title == 'Title' && showing.tags.empty? })
    assert_equal showings.map(&:booking_url).uniq, showings.map(&:booking_url)
  end

  def test_booking_links_take_the_whats_on_form
    assert_match %r{\A#{WebsiteStubs::CHORLEY}/booknow/\d+/\z}, parse('3915').first.booking_url
  end

  def test_summer_times_are_converted_to_utc
    html = '<option value="https://reel-cinemas.co.uk/reel-chorley/booknow/1">30 May 2027 @ 14:00</option>'
    showing = ReelUk::Internal::Parser::Showtimes.new(html, film_id: '1', title: 'Title',
                                                           venue_url: WebsiteStubs::CHORLEY).showings.first

    assert_equal Date.new(2027, 5, 30), showing.date
    assert_equal Time.utc(2027, 5, 30, 13, 0), showing.starting_at
  end

  def test_no_showtimes
    html = '<option disabled>No available showtimes</option>'

    assert_empty ReelUk::Internal::Parser::Showtimes.new(html, film_id: '1', title: 'Title',
                                                              venue_url: WebsiteStubs::CHORLEY).showings
  end

  private

  def parse(film_id)
    html = JSON.parse(website_fixture("showtimes-#{film_id}.json")).fetch('html')
    ReelUk::Internal::Parser::Showtimes.new(html, film_id: film_id, title: 'Title', venue_url: WebsiteStubs::CHORLEY).showings
  end
end
