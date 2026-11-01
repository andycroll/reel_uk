require_relative 'live_helper'

# Every venue's listings: about forty requests for each venue on the
# WordPress website, so this takes several minutes.
class LiveIntegrationTest < Minitest::Test
  def test_every_cinema_has_performances
    cinemas = ReelUk::Cinema.all
    today = Date.today

    assert_operator cinemas.size, :>=, 16
    assert_empty cinemas.map(&:id) - ReelUk::Cinema::LOCATIONS.keys

    cinemas.each do |cinema|
      performances = ReelUk::Performance.at(cinema.id, from: today, to: today + 365)

      assert(performances.all? { |p| p.instance_of?(ReelUk::Performance) })
      assert_operator performances.count, :>, 20, cinema.id
      assert_operator performances.map(&:showing_on).max, :>, today + 21, cinema.id
      assert(performances.all? { |p| p.booking_url.match?(ApiShapes::BOOKING_URL) }, cinema.id)
    end
  end
end
