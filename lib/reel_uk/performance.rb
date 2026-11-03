module ReelUk
  # A single screening of a film on the Reel Cinemas website
  class Performance < Cinebase::Performance
    # @!attribute [r] booking_url
    #   @return [String] the booking URL for the screening
    # @!attribute [r] cinema_name
    #   @return [String] the cinema name
    # @!attribute [r] cinema_id
    #   @return [String] the cinema id
    # @!attribute [r] dimension
    #   @return [String] 2d or 3d
    # @!attribute [r] film_name
    #   @return [String] the film name

    # @!method initialize(options)
    #   @param [Hash] options options hash
    #   @option options [String] :booking_url (nil) buying url for the screening
    #   @option options [String] :cinema_name name of the cinema
    #   @option options [String] :cinema_id website id of the cinema
    #   @option options [String] :dimension ('2d') dimension of the screening
    #   @option options [Cinebase::Festival] :festival (nil) festival edition
    #   @option options [String] :film_name name of the film
    #   @option options [Integer] :film_year (nil) year from the film's title
    #   @option options [String] :language (nil) audio language, e.g. 'Hindi'
    #   @option options [Time] :starting_at listed start time of the performance

    # Showtime labels and A1Web group headings, and the variants they mean.
    # 'Movie Madness' marks cheap tickets, not a kind of screening.
    VARIANTS = Cinebase::A1web::Performance::VARIANTS.merge(
      'ParentBaby' => 'baby',
      'Senior' => 'senior'
    ).freeze

    # Event screenings on the WordPress website have no label
    EVENT = /\A(?:RBO|NT Live|National Theatre Live|Met Opera|Exhibition on Screen)\b|\bLive On Stage\z|\s-\sThe Play\z/i
    SUBTITLED = /\bSubtitled\b/i
    THREE_D = Cinebase::A1web::Performance::THREE_D
    IMAX = Cinebase::A1web::Performance::IMAX
    LANGUAGE = Cinebase::A1web::Performance::LANGUAGE

    # The old website's own booking links only work in a browser that has
    # just visited the venue's pages, so link to the venue's Admit One
    # ticketing site, which redirects to seat selection.
    A1WEB_PERF_CODE = %r{/booking/(\d+)/}

    # Performances within an inclusive range of showing dates, from all of
    # the cinema's advertised dates. A venue on the WordPress website takes
    # three requests and one more for each film; a venue on the old A1Web
    # website takes one.
    # @param [String] cinema_id the venue's path on the website, e.g. 'chorley'
    # @param [Date] from first date (defaults to today in London)
    # @param [Date] to last date (defaults to 13 days after from)
    # @return [Array<ReelUk::Performance>]
    def self.at(
      cinema_id,
      from: Cinebase::London.today,
      to: from + 13
    )
      raise ArgumentError, 'to must not precede from' if to < from

      cinema = Cinema.new(cinema_id)
      performances = showings(cinema).select { |showing| (from..to).cover?(showing.date) }.map do |showing|
        new(attributes(showing, cinema).merge(cinema_id: cinema.id, cinema_name: cinema.name))
      end
      performances.sort_by(&:starting_at)
    end

    # @!method showing_on
    #   The date of the screening
    #   @return [Date]

    # @!method starting_at
    #   UTC time of the screening
    #   @return [Time]

    # @!method variant
    #   The kinds of screening (arts, baby, senior, subtitled ...)
    #   @return <Array[String]>

    def self.showings(cinema)
      if cinema.url.empty?
        []
      elsif cinema.a1web?
        html = Cinema.a1web_client.whats_on(cinema.url)
        Cinebase::A1web::Listings.new(html, venue_url: cinema.url, today: Cinebase::London.today).showings
      else
        ReelUk::Internal::Listings.new(cinema.url).showings
      end
    end
    private_class_method :showings

    def self.attributes(showing, cinema)
      title = showing.title
      {
        booking_url: booking_url(showing.booking_url, cinema),
        dimension: [title, *showing.tags].any? { |text| text.match?(THREE_D) } ? '3d' : '2d',
        festival: Cinebase::Festival.from_title(title, year: showing.date.year),
        film_name: ReelUk::Internal::TitleSanitizer.new(title).sanitized,
        film_year: Cinebase::TitleSanitizer.film_year(title),
        language: title[LANGUAGE, 1],
        starting_at: showing.starting_at,
        title: title,
        variant: variant(showing)
      }
    end
    private_class_method :attributes

    def self.booking_url(url, cinema)
      code = url[A1WEB_PERF_CODE, 1]
      if cinema.a1web? && code
        "https://reel#{cinema.id.delete('-')}.admit-one.co.uk/tickets/?perfCode=#{code}"
      else
        url
      end
    end
    private_class_method :booking_url

    def self.variant(showing)
      title = showing.title
      variant = showing.tags.filter_map { |tag| VARIANTS[tag] }
      variant << 'subtitled' if title.match?(SUBTITLED)
      variant << 'arts' if title.match?(EVENT)
      variant << 'imax' if title.match?(IMAX)
      variant.uniq
    end
    private_class_method :variant
  end
end
