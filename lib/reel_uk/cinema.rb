module ReelUk
  # The object representing a cinema on the Reel Cinemas website
  class Cinema < Cinebase::Cinema
    # @!attribute [r] id
    #   @return [String] the venue's path on the website, e.g. 'chorley'

    # Worker processes outlive a day's listings, so refetch the venue list
    CACHE_SECONDS = 3600

    # Most venues have moved to Reel's WordPress website. The rest are still
    # on its old Admit One A1Web website, which the cinema menu links.
    VENUE = %r{<option value="(https://(?:reel-cinemas|reelcinemas)\.co\.uk/([a-z-]+))/?">([^<]+)</option>}
    A1WEB_HOST = 'reelcinemas.co.uk'
    A1WEB_WEBSITE = 'https://reelcinemas.co.uk'
    # Menu names such as 'Fareham - Hampshire' add the county
    COUNTY = /\s+-\s+.*\z/

    # Venue pages give one-line addresses and no coordinates. Addresses come
    # from those page footers, coordinates from OpenStreetMap, apart from
    # Burnley's, from its postcode.
    LOCATIONS = {
      'bishop-auckland' => {
        street_address: 'Bishop Auckland Retail and Leisure Park', locality: 'Bishop Auckland',
        postal_code: 'DL14 9AA', latitude: 54.6383991, longitude: -1.6885187
      },
      'blackburn' => {
        street_address: 'Nab Lane', locality: 'Blackburn', region: 'Lancashire', postal_code: 'BB2 1LN',
        latitude: 53.7483439, longitude: -2.4868526
      },
      'borehamwood' => {
        street_address: 'Metropolis Centre', extended_address: '84 Shenley Road', locality: 'Borehamwood',
        region: 'Hertfordshire', postal_code: 'WD6 1EH', latitude: 51.6549265, longitude: -0.2747628
      },
      'bridgnorth' => {
        street_address: 'Whitburn Street', locality: 'Bridgnorth', region: 'Shropshire', postal_code: 'WV16 4QP',
        latitude: 52.535652, longitude: -2.4222158
      },
      'burnley' => {
        street_address: 'Unit 1, Pioneer Place', extended_address: 'Curzon Street', locality: 'Burnley',
        postal_code: 'BB11 1FB', latitude: 53.791753, longitude: -2.245629
      },
      'chippenham' => {
        street_address: 'Marshfield Road', locality: 'Chippenham', region: 'Wiltshire', postal_code: 'SN15 1JR',
        latitude: 51.4618773, longitude: -2.1207797
      },
      'chorley' => {
        street_address: 'Unit 6, Market Walk Extension', extended_address: 'Union Street', locality: 'Chorley',
        postal_code: 'PR7 1FD', latitude: 53.6539814, longitude: -2.628561
      },
      'fareham-hampshire' => {
        street_address: '3 Vannes Parade', extended_address: 'Market Quay', locality: 'Fareham',
        region: 'Hampshire', postal_code: 'PO16 0BX', latitude: 50.8519189, longitude: -1.1784328
      },
      'farnham-surrey' => {
        street_address: '8 Old Market Place', locality: 'Farnham', region: 'Surrey', postal_code: 'GU9 7SF',
        latitude: 51.2154964, longitude: -0.7948056
      },
      'hull' => {
        street_address: 'St Stephens Shopping Centre', extended_address: '110 Ferensway', locality: 'Hull',
        region: 'North Humberside', postal_code: 'HU2 8LN', latitude: 53.7450491, longitude: -0.3474325
      },
      'morecambe' => {
        street_address: 'Central Drive', locality: 'Morecambe', postal_code: 'LA4 4DW',
        latitude: 54.0707779, longitude: -2.8743043
      },
      'port-talbot' => {
        street_address: 'Hollywood Park', locality: 'Port Talbot', postal_code: 'SA12 6QW',
        latitude: 51.5926478, longitude: -3.8123333
      },
      'quinton' => {
        street_address: 'Hagley Road West', locality: 'Halesowen', region: 'West Midlands', postal_code: 'B62 9AS',
        latitude: 52.4625982, longitude: -2.0141104
      },
      'rochdale' => {
        street_address: 'Unit 22, Rochdale Riverside', extended_address: 'Riverside Walk', locality: 'Rochdale',
        postal_code: 'OL16 1BE', latitude: 53.6178417, longitude: -2.1558455
      },
      'wakefield' => {
        street_address: 'Unit 104-107, The Ridings Shopping Centre', extended_address: 'Almshouse Lane',
        locality: 'Wakefield', postal_code: 'WF1 1DS', latitude: 53.6816652, longitude: -1.4960074
      },
      'widnes' => {
        street_address: 'Unit 4, Venture Fields', extended_address: 'Earle Road', locality: 'Widnes',
        region: 'Cheshire', postal_code: 'WA8 0GY', latitude: 53.3624648, longitude: -2.723302
      }
    }.freeze

    ADDRESS_PARTS = %i(street_address extended_address locality region postal_code).freeze

    # Constructor
    # @param [String] id the venue's path on the website, e.g. 'chorley'
    # @return [ReelUk::Cinema]
    def initialize(id)
      @id = id.to_s.downcase
    end

    # Return basic cinema information for all cinemas, from the cinema menu
    # on the home page
    # @return [Array<ReelUk::Cinema>]
    # @example
    #   ReelUk::Cinema.all
    #   #=> [<ReelUk::Cinema>, <ReelUk::Cinema>, ...]
    def self.all
      venues_hash.keys.map { |id| new(id) }
    end

    # @return [Cinebase::A1web::Client] for venues still on the old website
    def self.a1web_client
      Cinebase::A1web::Client.new(base_url: A1WEB_WEBSITE)
    end

    # @!method address
    #   Address of the cinema
    #   @return [Hash] of different address parts
    #   @see #adr

    # Address of the cinema
    # @return [Hash] contains :street_address, :extended_address,
    # :locality, :region, :postal_code, :country_name
    # @example
    #   cinema = ReelUk::Cinema.new('borehamwood')
    #   cinema.adr
    #   #=> {
    #         street_address:   'Metropolis Centre',
    #         extended_address: '84 Shenley Road',
    #         locality:         'Borehamwood',
    #         region:           'Hertfordshire',
    #         postal_code:      'WD6 1EH',
    #         country_name:     'United Kingdom'
    #       }
    # @note Uses method naming as at http://microformats.org/wiki/adr
    def adr
      ADDRESS_PARTS.to_h { |part| [part, location[part]] }.merge(country_name: 'United Kingdom')
    end

    # @return [Boolean] whether the venue is still on the old A1Web website
    def a1web?
      URI(url).host == A1WEB_HOST
    end

    # Brand of the cinema
    # @return [String] which will always be 'Reel'
    def brand
      'Reel'.freeze
    end

    # @return [Float, nil]
    def latitude
      location[:latitude]
    end

    # @return [Float, nil]
    def longitude
      location[:longitude]
    end

    # The name of the cinema
    # @return [String]
    # @example
    #   ReelUk::Cinema.new('fareham-hampshire').name
    #   #=> 'Fareham'
    def name
      venue[:name].to_s
    end

    # The url of the cinema's pages on the Reel website
    # @return [String]
    # @example
    #   ReelUk::Cinema.new('chorley').url
    #   #=> 'https://reel-cinemas.co.uk/chorley'
    #   ReelUk::Cinema.new('hull').url
    #   #=> 'https://reelcinemas.co.uk/hull'
    def url
      venue[:url].to_s
    end

    # @api private
    def self.venues_hash
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      if @venues_hash.nil? || now - @fetched_at > CACHE_SECONDS
        @fetched_at = now
        html = ReelUk::Internal::Website.new.home
        @venues_hash = html.scan(VENUE).to_h do |url, id, name|
          [id, { url: url, name: CGI.unescapeHTML(name).sub(COUNTY, '').strip }]
        end
      end
      @venues_hash
    end
    private_class_method :venues_hash

    private

    def location
      LOCATIONS.fetch(id, {})
    end

    def venue
      self.class.send(:venues_hash).fetch(id, {})
    end
  end
end
