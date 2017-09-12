module ArticleJSON
  module Import
    module GoogleDoc
      module HTML
        class Parser
          # @param [String] html
          def initialize(html)
            doc = Nokogiri::HTML(html)
            @body_enumerator = doc.xpath('//body').last.children.to_enum

            css_node = doc.xpath('//head/style').last
            @css_analyzer = CSSAnalyzer.new(css_node&.inner_text)
          end

          # Parse the body of the document and return the result
          # @return [Array]
          def parsed_content
            @parsed_content ||= parse_body
          end

          private

          # Loop over all body nodes and parse them
          # @return [Array]
          def parse_body
            @parsed_content = []
            while body_has_more_nodes?
              @parsed_content << begin
                @current_node = NodeAnalyzer.new(@body_enumerator.next)
                parse_current_node || next
              end
            end
            @parsed_content
          end

          # Parse the current node and return an element, if available
          # @return [Object]
          def parse_current_node
            case @current_node.type
            when :heading then parse_heading
            when :paragraph then parse_paragraph
            when :list then parse_list
            when :image then parse_image
            when :text_box then parse_text_box
            when :quote then parse_quote
            when :embed then parse_embed
            when :hr, :empty, :unknown then nil
            end
          end

          # @return [ArticleJSON::Import::GoogleDoc::HTML::HeadingElement]
          def parse_heading
            HeadingElement.new(node: @current_node.node)
          end

          # @return [ArticleJSON::Import::GoogleDoc::HTML::ParagraphElement]
          def parse_paragraph
            ParagraphElement.new(
              node: @current_node.node,
              css_analyzer: @css_analyzer
            )
          end

          # @return [ArticleJSON::Import::GoogleDoc::HTML::ListElement]
          def parse_list
            ListElement.new(
              node: @current_node.node,
              css_analyzer: @css_analyzer
            )
          end

          # @return [ArticleJSON::Import::GoogleDoc::HTML::ImageElement]
          def parse_image
            ImageElement.new(
              node: @current_node.node,
              caption_node: @body_enumerator.next,
              css_analyzer: @css_analyzer
            )
          end

          # @return [ArticleJSON::Import::GoogleDoc::HTML::TextBoxElement]
          def parse_text_box
            nodes = []
            until NodeAnalyzer.new(@body_enumerator.peek).hr?
              nodes << @body_enumerator.next
            end
            TextBoxElement.new(nodes: nodes, css_analyzer: @css_analyzer)
          end

          # @return [ArticleJSON::Import::GoogleDoc::HTML::QuoteElement]
          def parse_quote
            nodes = []
            until NodeAnalyzer.new(@body_enumerator.peek).hr?
              nodes << @body_enumerator.next
            end
            QuoteElement.new(nodes: nodes, css_analyzer: @css_analyzer)
          end

          # @return [ArticleJSON::Import::GoogleDoc::HTML::EmbeddedElement]
          def parse_embed
            EmbeddedElement.build(
              node: @current_node.node,
              caption_node: @body_enumerator.next,
              css_analyzer: @css_analyzer
            )
          end

          # @return [Boolean]
          def body_has_more_nodes?
            @body_enumerator.peek
            true
          rescue StopIteration
            false
          end
        end
      end
    end
  end
end