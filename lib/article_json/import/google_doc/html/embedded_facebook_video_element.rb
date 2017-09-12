module ArticleJSON
  module Import
    module GoogleDoc
      module HTML
        class EmbeddedFacebookVideoElement < EmbeddedElement
          # The type of this embedded element
          # @return [Symbol]
          def embed_type
            :facebook_video
          end

          class << self
            # Regular expression to check if a given string is a FB Video URL
            # Also used to extract the ID from the URL
            # @return [Regexp]
            def url_regexp
              %r(
                ^\S*facebook.com/
                (?:\w+/videos/|video\.php\?v=|video\.php\?id=)
                ?(\d+)
              )xi
            end
          end
        end
      end
    end
  end
end