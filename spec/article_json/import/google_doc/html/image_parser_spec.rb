describe ArticleJSON::Import::GoogleDoc::HTML::ImageParser do
  subject(:element) do
    described_class.new(
      node: node,
      caption_node: caption_node,
      css_analyzer: css_analyzer
    )
  end
  let(:node) do
    Nokogiri::HTML.fragment(image_fragment.strip).first_element_child
  end
  let(:caption_node) do
    Nokogiri::HTML.fragment(caption_fragment.strip).first_element_child
  end
  let(:css_analyzer) do
    ArticleJSON::Import::GoogleDoc::HTML::CSSAnalyzer.new(css)
  end
  let(:css) { '' }
  let(:source_url) { 'foo/bar.jpg' }
  let(:image_fragment) { "<p><span><img src=\"#{source_url}\"></span></p>" }
  let(:caption_fragment) { '<p><span>foo</span></p>' }

  describe '#source_url' do
    subject { element.source_url }
    it { should eq source_url }
  end

  describe '#float' do
    subject { element.float }

    let(:css) do
      <<-css
        .center { text-align: center }
        .right { text-align: right }
      css
    end
    let(:image_fragment) do
      "<p class=\"#{p_class}\"><span>#{img_tag}</span></p>"
    end

    context 'for a image without width' do
      let(:img_tag) { '<img src="foo/bar">' }

      context 'and without alignment' do
        let(:p_class) { '' }
        it { should be nil }
      end

      context 'and with right-alignment' do
        let(:p_class) { 'right' }
        it { should be nil }
      end

      context 'and with left-alignment' do
        let(:p_class) { 'center' }
        it { should be nil }
      end
    end

    context 'for a image with a width-attribute' do
      context 'and not wider than 500px' do
        let(:img_tag) { '<img width="400" src="foo/bar">' }

        context 'and without alignment' do
          let(:p_class) { '' }
          it { should be :left }
        end

        context 'and with right-alignment' do
          let(:p_class) { 'right' }
          it { should be :right }
        end

        context 'and with left-alignment' do
          let(:p_class) { 'center' }
          it { should be nil }
        end
      end

      context 'and wider than 500px' do
        let(:img_tag) { '<img width="700" src="foo/bar">' }

        context 'and without alignment' do
          let(:p_class) { '' }
          it { should be nil }
        end

        context 'and with right-alignment' do
          let(:p_class) { 'right' }
          it { should be nil }
        end

        context 'and with left-alignment' do
          let(:p_class) { 'center' }
          it { should be nil }
        end
      end
    end

    context 'for a image with a style-attribute' do
      context 'and a width wider than 500px' do
        let(:img_tag) { '<img style="width: 400px;" src="foo/bar">' }

        context 'and without alignment' do
          let(:p_class) { '' }
          it { should be :left }
        end

        context 'and with right-alignment' do
          let(:p_class) { 'right' }
          it { should be :right }
        end

        context 'and with left-alignment' do
          let(:p_class) { 'center' }
          it { should be nil }
        end
      end

      context 'and wider than 500px' do
        let(:img_tag) { '<img style="width: 700px;" src="foo/bar">' }

        context 'and without alignment' do
          let(:p_class) { '' }
          it { should be nil }
        end

        context 'and with right-alignment' do
          let(:p_class) { 'right' }
          it { should be nil }
        end

        context 'and with left-alignment' do
          let(:p_class) { 'center' }
          it { should be nil }
        end
      end
    end
  end

  describe '#caption' do
    subject { element.caption }

    it 'returns a list of text elements' do
      expect(subject).to be_an Array
      expect(subject.size).to eq 1
      expect(subject).to all be_a ArticleJSON::Elements::Text
      expect(subject.first.content).to eq 'foo'
    end

    context 'when the caption nil' do
      let(:caption_node) { nil }
      it 'returns a list with one empty text element' do
        expect(subject).to be_an Array
        expect(subject.size).to eq 1
        expect(subject).to all be_a ArticleJSON::Elements::Text
        expect(subject.first.content).to eq '&nbsp;'
      end
    end
  end

  describe '#element' do
    subject { element.element }

    it 'returns a proper Hash' do
      expect(subject).to be_a ArticleJSON::Elements::Image
      expect(subject.type).to eq :image
      expect(subject.source_url).to eq source_url
      expect(subject.float).to be nil
      expect(subject.caption).to all be_a ArticleJSON::Elements::Text
    end
  end
end
