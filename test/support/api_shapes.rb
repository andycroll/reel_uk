# The parts of Reel's pages the gem reads. Checked against the trimmed
# fixtures and, in the live suite, against real pages held only in memory.
module ApiShapes
  VENUE_URL = %r{\Ahttps://(?:reel-cinemas|reelcinemas)\.co\.uk/[a-z-]+\z}
  BOOKING_URL = %r{\Ahttps://(?:reel-cinemas\.co\.uk/[a-z-]+/booknow/\d+/|reel[a-z]+\.admit-one\.co\.uk/tickets/\?perfCode=\d+)\z}
  SHOWTIME_HREF = %r{\A/[a-z-]+/booking/\d+/[\w-]+\z}
  A1WEB_SHOWTIME = %r{<a class="[^"]*perfButton[^"]*" href="([^"]*)"[^>]*>(.*?)</a>}m

  private

  def assert_home_shape(html)
    venues = html.scan(ReelUk::Cinema::VENUE)
    assert_operator venues.size, :>=, 10
    venues.each { |url, _id, name| assert_match VENUE_URL, url, name }
  end

  def assert_venue_shape(html)
    assert_match(/\A\d+\z/, html[ReelUk::Internal::Listings::LOCATION, 1])
  end

  def assert_whats_on_shape(html)
    parser = ReelUk::Internal::Parser::WhatsOn
    assert_operator html.scan(parser::BLOCK).size, :>, 1
    blocks = html.split(parser::BLOCK).drop(1).each_slice(2).map(&:last)
    blocks.each { |markup| assert_match parser::FILM, markup }
    showtimes = blocks.flat_map { |markup| markup.scan(parser::SHOWTIME) }
    refute_empty showtimes
    assert(showtimes.any? { |_id, _time, label| label })
  end

  def assert_coming_soon_shape(html)
    parser = ReelUk::Internal::Parser::ComingSoon
    films = html.split(parser::FILM_BLOCK).drop(1)
    refute_empty films
    films.each { |markup| assert_match parser::FILM, markup }
    assert(films.any? { |markup| markup.match?(parser::BOOKABLE) })
  end

  def assert_showtimes_shape(html)
    options = html.scan(ReelUk::Internal::Parser::Showtimes::OPTION)
    refute_empty options
    assert_equal html.scan(%r{/booknow/}).size, options.size
  end

  def assert_a1web_whats_on_shape(html)
    assert_match Cinebase::A1web::Listings::PANEL, html
    assert_match Cinebase::A1web::Listings::TAB, html
    assert_match Cinebase::A1web::Listings::FILM, html
    showtimes = html.scan(A1WEB_SHOWTIME)
    refute_empty showtimes
    showtimes.each do |href, button|
      assert_match SHOWTIME_HREF, href
      assert_match(/\A\s*\d{2}:\d{2}\s*\z/, button)
    end
  end
end
