describe ArticleJSON::Utils::OEmbedResolver::Base do
  subject(:resolver) { described_class.new(element) }

  let(:element) do
    ArticleJSON::Elements::Embed.new(
      embed_type: embed_type,
      embed_id: embed_id,
      caption: []
    )
  end

  describe '#oembed_data' do
    subject { resolver.oembed_data }

    let(:embed_id) { 'ABC' }
    let(:embed_type) { :foobar }
    let(:something_resolver) { double('something resolver') }
    let(:oembed_data) { { foo: :bar } }

    before do
      allow(described_class)
        .to receive(:build).with(element).and_return(something_resolver)
      allow(something_resolver)
        .to receive(:parsed_api_response).and_return(oembed_data)
    end

    it { should eq oembed_data }
  end

  describe '.build' do
    subject { described_class.build(element) }

    context 'when the element is a facebook video' do
      let(:embed_id) { '1814600831891266' }
      let(:embed_type) { :facebook_video }
      it { should be_a ArticleJSON::Utils::OEmbedResolver::FacebookVideo }
    end

    context 'when the element is a slideshare' do
      let(:embed_id) { 'Devex/the-best-global-development-quotes-of-2012' }
      let(:embed_type) { :slideshare }
      it { should be_a ArticleJSON::Utils::OEmbedResolver::Slideshare }
    end

    context 'when the element is a tweet' do
      let(:embed_id) { 'd3v3x/554608639030599681' }
      let(:embed_type) { :tweet }
      it { should be_a ArticleJSON::Utils::OEmbedResolver::Tweet }
    end

    context 'when the element is a vimeo video' do
      let(:embed_id) { '42315417' }
      let(:embed_type) { :vimeo_video }
      it { should be_a ArticleJSON::Utils::OEmbedResolver::VimeoVideo }
    end

    context 'when the element is a youtube video' do
      let(:embed_id) { '_ZG8HBuDjgc' }
      let(:embed_type) { :youtube_video }
      it { should be_a ArticleJSON::Utils::OEmbedResolver::YoutubeVideo }
    end

    context 'when the element is unknown' do
      let(:embed_id) { 'ABC' }
      let(:embed_type) { :foobar }
      it { should be nil }
    end
  end

  describe '.resolver_by_embed_type' do
    subject { described_class.resolver_by_embed_type(embed_type) }

    context 'when the element type is facebook_video' do
      let(:embed_type) { :facebook_video }
      it { should be ArticleJSON::Utils::OEmbedResolver::FacebookVideo }
    end

    context 'when the element type is slideshare' do
      let(:embed_type) { :slideshare }
      it { should be ArticleJSON::Utils::OEmbedResolver::Slideshare }
    end

    context 'when the element type is tweet' do
      let(:embed_type) { :tweet }
      it { should be ArticleJSON::Utils::OEmbedResolver::Tweet }
    end

    context 'when the element type is vimeo_video' do
      let(:embed_type) { :vimeo_video }
      it { should be ArticleJSON::Utils::OEmbedResolver::VimeoVideo }
    end

    context 'when the element type is youtube_video' do
      let(:embed_type) { :youtube_video }
      it { should be ArticleJSON::Utils::OEmbedResolver::YoutubeVideo }
    end

    context 'when the element type is unknown' do
      let(:embed_type) { :foo_bar }
      it { should be nil }
    end
  end
end
