require_relative 'fixtures_helper'

# Serve the fixtures in place of Reel's websites
module WebsiteStubs
  include FixturesHelper

  HOME = 'https://reel-cinemas.co.uk/'.freeze
  CHORLEY = 'https://reel-cinemas.co.uk/chorley'.freeze
  HULL = 'https://reelcinemas.co.uk/hull'.freeze
  AJAX = 'https://reel-cinemas.co.uk/wp-admin/admin-ajax.php'.freeze
  # Films whose every showtime the fixtures hold
  SCHEDULED_FILMS = %w(3758 3760 3915).freeze
  NO_SHOWTIMES = { html: '<option disabled>No available showtimes</option>' }.to_json.freeze
  # The A1Web fixture's tabs start on this date
  FETCHED_AT = Time.utc(2026, 11, 1, 12)

  private

  def stub_website
    stub_request(:get, HOME).to_return(status: 200, body: website_fixture('home.html'))
    stub_request(:get, "#{CHORLEY}/").to_return(status: 200, body: website_fixture('venue-chorley.html'))
    stub_request(:get, "#{CHORLEY}/whatson/").to_return(status: 200, body: website_fixture('whatson-chorley.html'))
    stub_request(:get, "#{CHORLEY}/comingsoon/").to_return(status: 200, body: website_fixture('comingsoon-chorley.html'))
    stub_request(:get, "#{HULL}/whatson").to_return(status: 200, body: website_fixture('whatson-hull.html'))
    stub_request(:post, AJAX).to_return(status: 200, body: NO_SHOWTIMES)
    SCHEDULED_FILMS.each do |film_id|
      stub_request(:post, AJAX).with(body: hash_including('select_movie' => film_id, 'movie_loc' => '9'))
                               .to_return(status: 200, body: website_fixture("showtimes-#{film_id}.json"))
    end
  end
end
