# frozen_string_literal: true

module ReelUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Reads pages from Reel's WordPress website, built on Jacro's cinema
    # plugin. No token is needed.
    class Website
      HOME = 'https://reel-cinemas.co.uk/'
      AJAX = 'https://reel-cinemas.co.uk/wp-admin/admin-ajax.php'
      # The quick booking menu's request for every showtime of a film
      SHOWTIMES_ACTION = 'display_showtime_byfilmid'

      def initialize
        @http = Cinebase::Http.new
      end

      # @return [String] the home page, whose cinema menu lists every venue
      def home
        @http.get(HOME)
      end

      # @param [String] venue_url e.g. 'https://reel-cinemas.co.uk/chorley'
      # @return [String] the venue's page, whose quick booking menu names
      #   the venue's Jacro location id
      def venue(venue_url)
        @http.get("#{venue_url}/")
      end

      # @param [String] venue_url e.g. 'https://reel-cinemas.co.uk/chorley'
      # @return [String] the next three weeks of showtimes, with labels
      def whats_on(venue_url)
        @http.get("#{venue_url}/whatson/")
      end

      # @param [String] venue_url e.g. 'https://reel-cinemas.co.uk/chorley'
      # @return [String] films not yet showing, with up to three showtimes each
      def coming_soon(venue_url)
        @http.get("#{venue_url}/comingsoon/")
      end

      # @param [String] film_id Jacro's film id, the same at every venue
      # @param [String] location Jacro's location id for the venue
      # @return [String] options naming every showtime of the film at the
      #   venue, however far ahead
      def showtimes(film_id, location)
        form = { 'action' => SHOWTIMES_ACTION, 'select_movie' => film_id, 'movie_loc' => location }
        response = @http.post(AJAX, form: form)
        JSON.parse(response).fetch('html', '').to_s
      end
    end
  end
end
