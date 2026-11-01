# frozen_string_literal: true

module ReelUk
  # @api private
  module Internal
    module Parser
      # Reads the films and showtimes on a venue's what's on page, which
      # covers the next three weeks. Each film has a block for each date,
      # with every showtime twice, for large and small screens.
      class WhatsOn
        BLOCK = /<div class="nowshowing_film_box_outer[^"]*?nowshowingslider_(\d{8})">/
        FILM = %r{<h2><a href="[^"]*/film/(\d+)/[^"]*">(.*?)</a></h2>}m
        SHOWTIME = %r{
          <a\shref="[^"]*/booknow/(\d+)/?"[^>]*>\s*(\d{1,2}:\d{2})\s*</a>
          (?:<div\sclass="show_time_label">([^<]*)</div>)?
        }x
        TIME_ZONE = 'Europe/London'

        # @param [String] html a what's on page
        # @param [String] venue_url e.g. 'https://reel-cinemas.co.uk/chorley'
        def initialize(html, venue_url:)
          @html = html
          @venue_url = venue_url
        end

        # @return [Hash{String => String}] titles by Jacro film id
        def films
          blocks.to_h { |_date, film_id, title, _markup| [film_id, title] }
        end

        # @return [Array<Cinebase::A1web::Showing>] each showtime once, with
        #   labels such as 'Senior' as tags
        def showings
          all = blocks.flat_map do |date, film_id, title, markup|
            markup.scan(SHOWTIME).map do |booking_id, time, label|
              Cinebase::A1web::Showing.new(
                film_id: film_id, title: title, date: date, starting_at: starting_at(date, time),
                booking_url: "#{@venue_url}/booknow/#{booking_id}/", tags: [label].compact
              )
            end
          end
          all.uniq(&:booking_url)
        end

        private

        def blocks
          @blocks ||= @html.split(BLOCK).drop(1).each_slice(2).filter_map do |key, markup|
            film = markup.to_s.match(FILM)
            [Date.strptime(key, '%Y%m%d'), film[1], CGI.unescapeHTML(film[2]).strip, markup] if film
          end
        end

        def starting_at(date, time)
          hour, minute = time.split(':').map(&:to_i)
          local = Time.utc(date.year, date.month, date.day, hour, minute)
          TZInfo::Timezone.get(TIME_ZONE).local_to_utc(local) { |periods| periods.first }.utc
        end
      end
    end
  end
end
