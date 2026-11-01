# frozen_string_literal: true

module ReelUk
  # @api private
  module Internal
    module Parser
      # Reads the films on a venue's coming soon page, which shows only
      # their first few showtimes
      class ComingSoon
        FILM_BLOCK = '<div class="grid-column">'
        FILM = %r{<h2><a href="[^"]*/film/(\d+)/[^"]*">(.*?)</a></h2>}m
        BOOKABLE = %r{/booknow/\d+}

        # @param [String] html a coming soon page
        def initialize(html)
          @html = html
        end

        # @return [Hash{String => String}] titles by Jacro film id, for films
        #   with showtimes on sale
        def films
          @html.split(FILM_BLOCK).drop(1).filter_map do |markup|
            film = markup.match(FILM)
            [film[1], CGI.unescapeHTML(film[2]).strip] if film && markup.match?(BOOKABLE)
          end.to_h
        end
      end
    end
  end
end
