require_relative '../../test_helper'

class ReelUk::CinemaTest < Minitest::Test
  include WebsiteStubs

  IDS = %w(bishop-auckland blackburn borehamwood bridgnorth burnley chippenham chorley fareham-hampshire
           farnham-surrey hull morecambe port-talbot quinton rochdale wakefield widnes).freeze

  def setup
    stub_website
    ReelUk::Cinema.instance_variable_set(:@venues_hash, nil)
  end

  def test_all_returns_every_venue_in_the_cinema_menu
    cinemas = ReelUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(ReelUk::Cinema) })
    assert_equal IDS, cinemas.map(&:id)
  end

  def test_all_reads_the_home_page_once_an_hour
    2.times { ReelUk::Cinema.all }

    assert_requested :get, HOME, times: 1
  end

  def test_new_stores_downcase_string_id
    assert_equal 'chorley', ReelUk::Cinema.new('Chorley').id
  end

  def test_name_full_name_and_slug
    cinema = ReelUk::Cinema.new('bishop-auckland')

    assert_equal 'Bishop Auckland', cinema.name
    assert_equal 'Reel Bishop Auckland', cinema.full_name
    assert_equal 'reel-bishop-auckland', cinema.slug
  end

  def test_names_leave_out_the_county
    assert_equal 'Fareham', ReelUk::Cinema.new('fareham-hampshire').name
    assert_equal 'Farnham', ReelUk::Cinema.new('farnham-surrey').name
  end

  def test_brand
    assert_equal 'Reel', ReelUk::Cinema.new('chorley').brand
  end

  def test_url_on_either_website
    assert_equal CHORLEY, ReelUk::Cinema.new('chorley').url
    assert_equal HULL, ReelUk::Cinema.new('hull').url
  end

  def test_venues_on_the_old_website
    assert_equal %w(hull morecambe quinton), ReelUk::Cinema.all.select(&:a1web?).map(&:id)
  end

  def test_adr
    expected = {
      street_address:   'Metropolis Centre',
      extended_address: '84 Shenley Road',
      locality:         'Borehamwood',
      region:           'Hertfordshire',
      postal_code:      'WD6 1EH',
      country_name:     'United Kingdom'
    }

    assert_equal expected, ReelUk::Cinema.new('borehamwood').adr
  end

  def test_coordinates
    cinema = ReelUk::Cinema.new('hull')

    assert_in_delta 53.7450491, cinema.latitude
    assert_in_delta(-0.3474325, cinema.longitude)
  end

  def test_every_venue_has_a_postcode_and_coordinates
    ReelUk::Cinema.all.each do |cinema|
      refute_empty cinema.locality, cinema.id
      assert_match(/\A[A-Z]{1,2}\d{1,2} \d[A-Z]{2}\z/, cinema.postal_code, cinema.id)
      assert_kind_of Float, cinema.latitude, cinema.id
      assert_kind_of Float, cinema.longitude, cinema.id
    end
  end

  def test_unknown_cinema_has_no_details
    cinema = ReelUk::Cinema.new('nowhere')

    assert_equal '', cinema.name
    assert_equal '', cinema.url
    refute cinema.a1web?
    assert_nil cinema.latitude
  end
end
