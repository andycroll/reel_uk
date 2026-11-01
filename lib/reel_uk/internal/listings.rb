# frozen_string_literal: true

module ReelUk
  # @api private
  module Internal
    # Every showtime a venue on Reel's WordPress website has on sale. The
    # what's on page covers three weeks and the coming soon page only a
    # film's first few showtimes, so the quick booking menu's request for
    # each film on either page fills in the rest, one request per film.
    # Labels such as 'Senior' are only on the what's on page.
    class Listings
      LOCATION = /attr_loc="(\d+)"/

      # @param [String] venue_url e.g. 'https://reel-cinemas.co.uk/chorley'
      # @param [ReelUk::Internal::Website] website
      def initialize(venue_url, website: Website.new)
        @venue_url = venue_url
        @website = website
      end

      # @return [Array<Cinebase::A1web::Showing>] each showtime once
      def showings
        whats_on = Parser::WhatsOn.new(@website.whats_on(@venue_url), venue_url: @venue_url)
        films = Parser::ComingSoon.new(@website.coming_soon(@venue_url)).films.merge(whats_on.films)
        (whats_on.showings + scheduled(films)).uniq(&:booking_url)
      end

      private

      # Without a location id, only the what's on page's showtimes are known
      def scheduled(films)
        location = @website.venue(@venue_url)[LOCATION, 1]
        if location
          films.flat_map do |film_id, title|
            html = @website.showtimes(film_id, location)
            Parser::Showtimes.new(html, film_id: film_id, title: title, venue_url: @venue_url).showings
          end
        else
          []
        end
      end
    end
  end
end
