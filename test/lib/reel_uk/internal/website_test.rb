require_relative '../../../test_helper'

class ReelUk::Internal::WebsiteTest < Minitest::Test
  include WebsiteStubs

  def setup
    stub_website
    @website = ReelUk::Internal::Website.new
  end

  def test_showtimes_posts_the_quick_booking_request
    html = @website.showtimes('3915', '9')

    assert_match %r{/booknow/\d+}, html
    assert_requested :post, AJAX, body: { 'action' => 'display_showtime_byfilmid', 'select_movie' => '3915',
                                          'movie_loc' => '9' }
  end

  def test_showtimes_without_html_are_empty
    stub_request(:post, AJAX).to_return(status: 200, body: '{}')

    assert_equal '', @website.showtimes('1', '9')
  end

  def test_errors_name_the_status_and_host_but_not_the_body
    stub_request(:get, HOME).to_return(status: 403, body: 'secret')

    error = assert_raises(RuntimeError) { @website.home }
    assert_equal 'Reel HTTP error 403 from reel-cinemas.co.uk', error.message
  end

  def test_redirects_are_not_followed
    stub_request(:get, HOME).to_return(status: 302, headers: { 'Location' => 'https://reel-cinemas.co.uk/x' })

    assert_raises(RuntimeError) { @website.home }
  end

  def test_transient_errors_are_retried
    stub_request(:get, HOME).to_raise(Errno::ECONNRESET).then.to_return(status: 200, body: 'ok')

    @website.stub(:sleep, nil) { assert_equal 'ok', @website.home }
    assert_requested :get, HOME, times: 2
  end

  def test_retries_give_up
    stub_request(:get, HOME).to_raise(Net::ReadTimeout)

    assert_raises(Net::ReadTimeout) { @website.stub(:sleep, nil) { @website.home } }
    assert_requested :get, HOME, times: 3
  end
end
