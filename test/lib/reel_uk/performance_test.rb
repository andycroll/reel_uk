require_relative '../../test_helper'

class ReelUk::PerformanceTest < Minitest::Test
  include WebsiteStubs

  DATE = Date.new(2026, 11, 1)
  BOOKNOW = "#{WebsiteStubs::CHORLEY}/booknow/".freeze
  TICKETS = 'https://reelhull.admit-one.co.uk/tickets/?perfCode='.freeze

  def setup
    stub_website
    ReelUk::Cinema.instance_variable_set(:@venues_hash, nil)
  end

  def test_at_returns_performances_in_time_order
    performances = performances_at('chorley')

    assert(performances.all? { |p| p.instance_of?(ReelUk::Performance) })
    assert_equal 69, performances.count
    assert_equal performances.map(&:starting_at).sort, performances.map(&:starting_at)
  end

  def test_at_asks_for_every_showtime_of_each_film
    performances_at('chorley')

    %w(/ /whatson/ /comingsoon/).each { |path| assert_requested :get, "#{CHORLEY}#{path}", times: 1 }
    assert_requested :post, AJAX, times: 9
    assert_requested :post, AJAX, times: 1, body: hash_including('select_movie' => '3760', 'movie_loc' => '9')
  end

  def test_at_keeps_to_the_range
    assert_equal 6, ReelUk::Performance.at('chorley', from: DATE, to: DATE).count
  end

  def test_at_sets_cinema_details
    performances = performances_at('chorley')

    assert_equal ['chorley'], performances.map(&:cinema_id).uniq
    assert_equal ['Chorley'], performances.map(&:cinema_name).uniq
  end

  def test_at_parses_first_performance
    performance = performances_at('chorley').first

    assert_equal 'Forgotten Island', performance.film_name
    assert_nil performance.film_year
    assert_equal Time.utc(2026, 11, 1, 10, 0), performance.starting_at
    assert_equal '2d', performance.dimension
    assert_empty performance.variant
    assert_equal "#{BOOKNOW}34266/", performance.booking_url
  end

  def test_senior_screenings
    assert_equal %w(senior), find('34322').variant
  end

  def test_subtitled_screenings_are_listed_as_films
    performance = find('34324')

    assert_equal 'Wicker', performance.film_name
    assert_equal %w(subtitled), performance.variant
  end

  def test_events_are_arts
    assert_equal %w(arts), find('31612').variant
    assert_equal %w(arts), find('30617').variant
  end

  def test_showtimes_beyond_the_whats_on_page
    hunger_games = performances_at('chorley').select { |p| p.film_name.start_with?('The Hunger Games') }

    assert_equal 1, hunger_games.count { |p| p.booking_url == "#{BOOKNOW}34348/" }
    assert_operator hunger_games.map(&:showing_on).max, :>, Date.new(2026, 11, 22)
  end

  def test_films_not_yet_showing
    performance = find('32759')

    assert_equal 'Avengers: Doomsday', performance.film_name
    assert_equal Time.utc(2026, 12, 16, 9, 30), performance.starting_at
  end

  def test_royal_ballet_and_opera
    performance = performances_at('chorley').detect { |p| p.film_name == 'Royal Ballet and Opera: The Nutcracker' }

    assert_equal %w(arts), performance.variant
  end

  def test_without_a_location_only_the_whats_on_page_is_read
    stub_request(:get, "#{CHORLEY}/").to_return(status: 200, body: '<html></html>')

    assert_equal 19, performances_at('chorley').count
    assert_not_requested :post, AJAX
  end

  def test_venues_on_the_old_website
    performances = Time.stub(:now, FETCHED_AT) { performances_at('hull') }

    assert_equal 8, performances.count
    assert_equal "#{TICKETS}34037", performances.detect { |p| p.film_name == 'Forgotten Island' }.booking_url
    assert_equal ['hull'], performances.map(&:cinema_id).uniq
  end

  def test_old_website_headings
    performances = Time.stub(:now, FETCHED_AT) { performances_at('hull') }
    doctor_who = performances.detect { |p| p.film_name == 'Doctor Who: The Satan Pit' }

    assert_equal %w(arts), doctor_who.variant
    assert(performances.none? { |p| p.variant.include?('Movie Madness') })
  end

  def test_old_website_links_without_a_code_are_kept
    stub_request(:get, "#{HULL}/whatson").to_return(
      status: 200, body: website_fixture('whatson-hull.html').sub('/hull/booking/34037/', '/hull/film/')
    )
    performances = Time.stub(:now, FETCHED_AT) { performances_at('hull') }
    performance = performances.detect { |p| p.film_name == 'Forgotten Island' }

    assert_equal "#{HULL}/film/forgotten-island", performance.booking_url
  end

  def test_unknown_cinema_has_no_performances
    assert_empty performances_at('nowhere')
    assert_not_requested :get, "#{CHORLEY}/whatson/"
  end

  def test_to_must_not_precede_from
    assert_raises(ArgumentError) { ReelUk::Performance.at('chorley', from: DATE, to: DATE - 1) }
  end

  private

  def performances_at(cinema_id)
    ReelUk::Performance.at(cinema_id, from: DATE, to: DATE + 365)
  end

  def find(booking_id)
    performances_at('chorley').detect { |p| p.booking_url == "#{BOOKNOW}#{booking_id}/" }
  end
end
