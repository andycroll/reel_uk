module ReelUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Sanitize and standardize film titles
    class TitleSanitizer < Cinebase::TitleSanitizer
      # @!method initialize(title)
      #   Constructor
      #   @param [String] title a film title
      #   @return [ReelUk::Internal::TitleSanitizer]

      # @!method sanitized
      #   sanitized and standardized title
      #   @return [String] sanitised title

      private

      # strings and regex to be removed
      def remove
        [
          /\s+-\s+Subtitled(?: Screening)?\z/i, # subtitled copy
          /(?::|\s+-)?\s+3D\b/i,                # 3D copy, e.g. ': 3D' or ' - 3D'
          /\s+I Infinity Vision\z/i,            # premium screen copy
          /\ASee It First\s+-\s+/i              # preview
        ] + COMMON_REMOVE
      end

      # regexes and their replacements
      def replace
        {
          /\ANT Live: (.*)/                       => 'National Theatre Live: ',
          /\ARBO 20\d{2}-(?:20)?\d{2}: (.*)/      => 'Royal Ballet and Opera: '
        }.merge(COMMON_REPLACE)
      end
    end
  end
end
