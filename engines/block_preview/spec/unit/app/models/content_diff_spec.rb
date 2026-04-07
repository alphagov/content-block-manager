RSpec.describe BlockPreview::ContentDiff do
  subject(:content_diff) { described_class.new(html, block) }

  let(:content_id) { SecureRandom.uuid }
  let(:block) { instance_double("ContentBlock", content_id:) }

  describe "#to_s" do
    context "when govspeak includes a matching embedded content block" do
      let(:html) do
        Nokogiri::HTML.parse(<<~HTML)
          <html>
            <body>
              <div data-module="govspeak">
                <p>Before content</p>
                <span data-content-id="#{content_id}" data-embed-code="embed-1">Old block</span>
              </div>
            </body>
          </html>
        HTML
      end

      before do
        allow(block).to receive(:render).with("embed-1").and_return("<span>Rendered block</span>")
      end

      it "returns a diff fragment marked with compare-editions" do
        parsed = Nokogiri::HTML.fragment(content_diff.to_s)

        expect(parsed.at_css(".compare-editions")).to be_present
      end

      it "renders the replacement content in the diff output" do
        parsed = Nokogiri::HTML.fragment(content_diff.to_s)

        expect(parsed.text).to include("Rendered block")
      end
    end

    context "when govspeak has both matching and non-matching embedded blocks" do
      let(:other_content_id) { SecureRandom.uuid }
      let(:html) do
        Nokogiri::HTML.parse(<<~HTML)
          <html>
            <body>
              <div data-module="govspeak">
                <span data-content-id="#{content_id}" data-embed-code="embed-1">Old matching block</span>
                <span data-content-id="#{other_content_id}" data-embed-code="embed-2">Old non-matching block</span>
              </div>
            </body>
          </html>
        HTML
      end

      before do
        allow(block).to receive(:render).with("embed-1").and_return("<span>Rendered matching block</span>")
      end

      it "only renders replacements for wrappers with the target content id" do
        content_diff.to_s

        expect(block).to have_received(:render).with("embed-1").once
      end

      it "keeps non-matching content visible in the resulting diff" do
        parsed = Nokogiri::HTML.fragment(content_diff.to_s)

        expect(parsed.text).to include("Old non-matching block")
      end
    end

    context "when multiple wrappers match the target content id" do
      let(:html) do
        Nokogiri::HTML.parse(<<~HTML)
          <html>
            <body>
              <div data-module="govspeak">
                <span data-content-id="#{content_id}" data-embed-code="embed-1">Old block 1</span>
                <span data-content-id="#{content_id}" data-embed-code="embed-2">Old block 2</span>
              </div>
            </body>
          </html>
        HTML
      end

      before do
        allow(block).to receive(:render).with("embed-1").and_return("<span>Rendered block 1</span>")
        allow(block).to receive(:render).with("embed-2").and_return("<span>Rendered block 2</span>")
      end

      it "renders each matching wrapper using its embed code" do
        content_diff.to_s

        expect(block).to have_received(:render).with("embed-1").once
        expect(block).to have_received(:render).with("embed-2").once
      end
    end

    context "when a matching wrapper has no embed code" do
      let(:html) do
        Nokogiri::HTML.parse(<<~HTML)
          <html>
            <body>
              <div data-module="govspeak">
                <span data-content-id="#{content_id}">Old block</span>
              </div>
            </body>
          </html>
        HTML
      end

      before do
        allow(block).to receive(:render).with(nil).and_return("<span>Rendered without embed code</span>")
      end

      it "passes nil to the renderer and still returns output" do
        output = content_diff.to_s

        expect(block).to have_received(:render).with(nil)
        expect(output).to include("compare-editions")
      end
    end

    context "when the source html has no govspeak node" do
      let(:html) do
        Nokogiri::HTML.parse(<<~HTML)
          <html>
            <body>
              <p>No govspeak content here</p>
            </body>
          </html>
        HTML
      end

      it "raises an error when generating the diff" do
        expect { content_diff.to_s }.to raise_error(NoMethodError)
      end
    end
  end
end
