
# Existing matchers don't check multipart emails correctly

module Mail
  module Matchers
    class HasSentEmailMatcher

      def matches_on_body?(delivery)
        delivery.body == @body || delivery.body.encoded == @body
      end

      def matches_on_body_matcher?(delivery)
        (@body_matcher.match delivery.body.raw_source) || (@body_matcher.match delivery.body.encoded)
      end

    end
  end
end
