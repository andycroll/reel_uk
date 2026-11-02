# frozen_string_literal: true

module ReelUk
  # @api private
  module Internal
    module Parser
      # Reads the quick booking menu's options for one film at one venue,
      # such as '16 Dec 2026 @ 09:30', which name every showtime on sale
      class Showtimes
        OPTION = %r{<option value="[^"]*/booknow/(\d+)/?">(\d{1,2} [A-Z][a-z]{2} \d{4}) @ (\d{1,2}):(\d{2})</option>}

        # @param [String] html the menu's options
        # @param [String] film_id Jacro's film id
        # @param [String] title the film's title
        # @param [String] venue_url e.g. 'https://reel-cinemas.co.uk/chorley'
        def initialize(html, film_id:, title:, venue_url:)
          @html = html
          @film_id = film_id
          @title = title
          @venue_url = venue_url
        end

        # Options link through a 'reel-chorley' path that redirects, so
        # booking links take the what's on page's form
        # @return [Array<Cinebase::A1web::Showing>] without tags
        def showings
          @html.scan(OPTION).map do |booking_id, day, hour, minute|
            date = Date.strptime(day, '%d %b %Y')
            Cinebase::A1web::Showing.new(
              film_id: @film_id, title: @title, date: date, starting_at: starting_at(date, hour, minute),
              booking_url: "#{@venue_url}/booknow/#{booking_id}/", tags: []
            )
          end
        end

        private

        def starting_at(date, hour, minute)
          local = Time.utc(date.year, date.month, date.day, hour.to_i, minute.to_i)
          Cinebase::London.utc(local)
        end
      end
    end
  end
end
