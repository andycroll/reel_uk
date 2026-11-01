require 'cgi/escape'
require 'json'

require 'cinebase'
require 'cinebase/a1web'

require_relative './reel_uk/version'

require_relative './reel_uk/internal/http'
require_relative './reel_uk/internal/website'
require_relative './reel_uk/internal/title_sanitizer'

require_relative './reel_uk/internal/parser/coming_soon'
require_relative './reel_uk/internal/parser/showtimes'
require_relative './reel_uk/internal/parser/whats_on'
require_relative './reel_uk/internal/listings'

require_relative './reel_uk/cinema'
require_relative './reel_uk/performance'

# reel_uk gem
module ReelUk
end
