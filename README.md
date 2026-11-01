# ReelUk

A simple gem to pull cinemas and performances from the [Reel Cinemas website](https://reel-cinemas.co.uk) and spit out useful formatted info.

## Installation

Add this line to your application's Gemfile:

    gem 'reel_uk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install reel_uk

## Usage

The gem conforms to the API set down in the `cinebase` gem, [andycroll/cinebase](https://github.com/andycroll/cinebase), which provides a lot of useful base vocabulary and repetitive code for this series of cinema focussed gems.

Performance titles are sanitized as much as possible, removing subtitled, 3D
and premium screen copies, preview prefixes, anniversaries and years, and
naming National Theatre Live and Royal Ballet and Opera screenings in full.

No token or setup is needed. Reel is moving from Admit One's A1Web website,
`reelcinemas.co.uk`, to a WordPress website, `reel-cinemas.co.uk`, built on
Jacro's cinema plugin with TapOS ticketing. Most venues have moved. The cinema
menu on the new home page links each venue's pages on whichever website it
uses, and the gem reads each venue from there: the new website itself, or the
old one through cinebase's shared `Cinebase::A1web` support. A venue that
moves keeps its id, its path on both websites.

### Cinema

The venue list is cached for an hour. Reading it takes one request for the home
page. Venue pages give one-line addresses and no coordinates, so the gem holds
them: addresses from the page footers and coordinates from OpenStreetMap,
apart from Burnley's, which is not mapped and comes from its postcode.

``` ruby
ReelUk::Cinema.all
#=> [<ReelUk::Cinema ...>, <ReelUk::Cinema ...>, ...]

cinema = ReelUk::Cinema.new('borehamwood')
#=> <ReelUk::Cinema ...>

cinema.adr
#=> {
  street_address:   'Metropolis Centre',
  extended_address: '84 Shenley Road',
  locality:         'Borehamwood',
  region:           'Hertfordshire',
  postal_code:      'WD6 1EH',
  country_name:     'United Kingdom'
}

cinema.brand
#=> 'Reel'

cinema.full_name
#=> 'Reel Borehamwood'

cinema.id
#=> 'borehamwood'

cinema.latitude
#=> 51.6549265

cinema.url
#=> 'https://reel-cinemas.co.uk/borehamwood'

cinema.a1web?
#=> false # true for venues still on reelcinemas.co.uk
```

### Performances

`Performance.at` returns performances for an inclusive range of showing dates,
defaulting to today in London and the following 13 days. It always reads every
advertised date.

On the WordPress website the what's on page covers three weeks and the coming
soon page shows only a film's first few showtimes. The gem reads both, then
asks the quick booking menu for every showtime of each film on either page:
three requests and one more for each film, about forty for a venue, which
takes half a minute. On the old A1Web website the what's on page holds every
date, so it is one request.

``` ruby
ReelUk::Performance.at('chorley', from: Date.today, to: Date.today + 2)
#=> [<ReelUk::Performance ...>, <ReelUk::Performance ...>, ...]

performance = ReelUk::Performance.at('chorley').detect(&:subtitled?)
#=> <ReelUk::Performance ...>

performance.film_name
#=> 'Wicker' # from 'Wicker - Subtitled Screening'

performance.film_year
#=> nil # from the title, e.g. 1981 for 'The Evil Dead (1981)'

performance.language
#=> nil # e.g. 'Hindi' from 'Ramayana: Rise of a Legend: 3D (Hindi)'

performance.dimension
#=> '2d'

performance.variant
#=> ['subtitled']

performance.subtitled?
#=> true

performance.starting_at
#=> 2026-11-03 17:15:00 UTC

performance.booking_url
#=> 'https://reel-cinemas.co.uk/chorley/booknow/34324/'

performance.cinema_name
#=> 'Chorley'

performance.cinema_id
#=> 'chorley'
```

Booking links on the WordPress website open the TapOS booking for the
showtime in the venue's pages. Venues on the old website link to their Admit
One ticketing site, such as
`https://reelhull.admit-one.co.uk/tickets/?perfCode=34037`, which redirects to
seat selection; the old website's own booking links only work in a browser
that has just visited the venue's pages.

Variants are `arts` (event cinema, from A1Web's 'Event Cinema' heading or, on
the WordPress website, from titles such as 'RBO' and 'NT Live'), `baby`,
`imax`, `kids`, `relaxed`, `senior` and `subtitled`. Showtime labels such as
'Senior' are only on the WordPress website's what's on page, so showtimes
beyond its three weeks have none until they come into range. 'Movie Madness'
marks cheap tickets and is not a variant.

## Tests

```sh
bundle exec rake          # unit tests against fixtures
bundle exec rake live     # live reel-cinemas.co.uk and reelcinemas.co.uk, several minutes
```

Fixtures in `test/fixtures` are captured from both websites and trimmed: the
home page's cinema menu, Chorley's quick booking menu, what's on page and
coming soon page with a few films on a few dates, the quick booking menu's
showtimes for three films, and Hull's A1Web what's on page with a few films on
a few dates. `test/support/api_shapes.rb` describes the parts of the pages the
gem reads. The unit suite checks the fixtures against it and the live suite
checks real responses, held only in memory. When the websites change, update
the shape first, then the fixtures.

## Releasing

Bump the version, merge, then run the **Release Gem** workflow in GitHub
Actions. It runs the tests, tags the version and publishes the gem through
RubyGems trusted publishing.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
