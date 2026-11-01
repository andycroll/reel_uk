# frozen_string_literal: true

require 'net/http'

module ReelUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Requests to reel-cinemas.co.uk
    module Http
      RETRIES = 2
      TRANSIENT_ERRORS = [
        EOFError, Errno::ECONNRESET, Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError
      ].freeze

      private

      def get(url)
        perform(Net::HTTP::Get.new(URI(url)))
      end

      def post(url, form)
        post = Net::HTTP::Post.new(URI(url))
        post.set_form_data(form)
        perform(post)
      end

      def perform(request)
        uri = request.uri
        attempts = 0
        begin
          response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30) do |http|
            http.request(request)
          end
        rescue *TRANSIENT_ERRORS
          attempts += 1
          raise if attempts > RETRIES

          sleep(attempts)
          retry
        end
        # Omit response bodies from errors, and never follow redirects.
        raise "Reel HTTP error #{response.code} from #{uri.host}" unless response.is_a?(Net::HTTPSuccess)

        String.new(response.body, encoding: Encoding::UTF_8)
      end
    end
  end
end
