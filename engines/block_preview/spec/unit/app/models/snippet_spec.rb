RSpec.describe BlockPreview::Snippet do
  describe ".for_content_id" do
    let(:content_id) { SecureRandom.uuid }
    let(:base_path) { "/test-path" }
    let(:block) { instance_double("ContentBlock") }
    let(:diff_output) { "<main>DIFF_HTML</main>" }
    let(:snippets) { [instance_double(described_class)] }
    let(:publishing_api_response) { { "base_path" => base_path } }
    let(:content_store) { instance_double("ContentStore") }
    let(:diff) { instance_double(BlockPreview::ContentDiff, to_s: diff_output) }

    before do
      allow(Public::Services.publishing_api).to receive(:get_content)
        .with(content_id)
        .and_return(publishing_api_response)
      allow(described_class).to receive(:from_html).with(diff_output).and_return(snippets)
      allow(BlockPreview::ContentDiff).to receive(:new).and_return(diff)
    end

    it "fetches published content from the live content store and parses details.body" do
      allow(Public::Services).to receive(:content_store).and_return(content_store)
      allow(content_store).to receive(:content_item).with(base_path).and_return(
        {
          "document_type" => "answer",
          "details" => { "body" => "<p>Published body</p>" },
        },
      )

      expect(BlockPreview::ContentDiff).to receive(:new) { |html_fragment, received_block|
        expect(html_fragment).to be_a(Nokogiri::HTML::DocumentFragment)
        expect(html_fragment.to_html).to eq("<p>Published body</p>")
        expect(received_block).to be(block)
      }.and_return(diff)

      expect(described_class.for_content_id(content_id, state: "published", block:)).to eq(snippets)
    end

    it "fetches draft content from the draft store and joins guide parts into a single fragment" do
      allow(Public::Services).to receive(:draft_content_store).and_return(content_store)
      allow(content_store).to receive(:content_item).with(base_path).and_return(
        {
          "document_type" => "guide",
          "details" => {
            "parts" => [
              { "body" => "<p>Part one</p>" },
              { "body" => "<p>Part two</p>" },
            ],
          },
        },
      )

      expect(BlockPreview::ContentDiff).to receive(:new) { |html_fragment, _received_block|
        expect(html_fragment).to be_a(Nokogiri::HTML::DocumentFragment)
        expect(html_fragment.to_html).to include("<p>Part one</p>")
        expect(html_fragment.to_html).to include("<p>Part two</p>")
      }.and_return(diff)

      described_class.for_content_id(content_id, state: "draft", block:)
    end
  end

  describe ".from_html" do
    it "returns an empty array when there are no content blocks" do
      html = <<~HTML
        <main>
          <p>No embeds here</p>
        </main>
      HTML

      expect(described_class.from_html(html)).to eq([])
    end

    it "returns one snippet per content block when they are separate" do
      html = <<~HTML
        <main>
          <p>Lead paragraph</p>
          <p><span class="content-block">A</span></p>
          <p>Gap one</p>
          <p>Gap two</p>
          <p>Gap three</p>
          <p><span class="content-block">B</span></p>
          <p>Tail paragraph</p>
        </main>
      HTML

      snippets = described_class.from_html(html)

      expect(snippets.count).to eq(2)
      expect(snippets.map(&:to_html).join("\n")).to include("A")
      expect(snippets.map(&:to_html).join("\n")).to include("B")
    end

    it "de-duplicates snippets when multiple content blocks share the same parent" do
      html = <<~HTML
        <main>
          <p>Lead paragraph</p>
          <p>
            <span class="content-block">A</span>
            <span class="content-block">B</span>
          </p>
          <p>Tail paragraph</p>
        </main>
      HTML

      snippets = described_class.from_html(html)

      expect(snippets.count).to eq(1)
      expect(snippets.first.to_html).to include("A")
      expect(snippets.first.to_html).to include("B")
    end

    it "de-duplicates a later snippet when its list is already included in an earlier snippet" do
      html = <<~HTML
        <main>
          <p>Lead paragraph</p>
          <div class="diff">
            <ins>
              The full rate is <span class="content-block">£122.55</span>
            </ins>
          </div>
          <ul>
            <li>Unchanged item</li>
            <li>
              <div class="diff">
                <ins>
                  Something about the pension rate <span class="content-block">£122.55</span> in a list item
                </ins>
              </div>
            </li>
            <li>Another unchanged item</li>
          </ul>
          <p>Tail paragraph</p>
        </main>
      HTML

      snippets = described_class.from_html(html)

      expect(snippets.count).to eq(1)
      expect(snippets.first.to_html).to include("<ul>")
      expect(snippets.first.to_html.scan("<ul>").count).to eq(1)
    end

    it "keeps later snippets whose parent is not already present in an earlier snippet" do
      html = <<~HTML
        <main>
          <p>Your State Pension amount depends on your National Insurance record.</p>
          <p>Check your State Pension forecast.</p>
          <div class="diff">
            <del>
              <p>The full rate is <span class="content-block">£122.40</span>.</p>
            </del>
          </div>
          <div class="diff">
            <ins>
              <p>The full rate is <span class="content-block">£122.55</span>.</p>
            </ins>
          </div>
          <ul>
            <li>if you were contracted out before 2016</li>
            <li>
              <div class="diff">
                <del>Something about the pension rate <span class="content-block">£122.40</span> in a list item</del>
              </div>
            </li>
            <li>
              <div class="diff">
                <ins>Something about the pension rate <span class="content-block">£122.55</span> in a list item</ins>
              </div>
            </li>
          </ul>
          <p>Find out what tax you might pay.</p>
          <div class="diff">
            <del>
              <h2>If you’re getting less than <span class="content-block">£122.40</span> a week</h2>
            </del>
          </div>
          <div class="diff">
            <ins>
              <h2>If you’re getting less than <span class="content-block">£122.55</span> a week</h2>
            </ins>
          </div>
          <p>You might need more qualifying years.</p>
        </main>
      HTML

      snippets = described_class.from_html(html)

      expect(snippets.count).to eq(2)
      expect(snippets.first.to_html).to include("<ul>")
      expect(snippets.last.to_html).to include("If you’re getting less than")
      expect(snippets.last.to_html).not_to include("Something about the pension rate")
      expect(snippets.map(&:to_html).join("\n").scan("Something about the pension rate").count).to eq(2)
    end
  end

  describe "#to_html" do
    let(:doc) { Nokogiri::HTML(html) }
    let(:block) { doc.at_css(css_selector) }
    let(:snippet) { described_class.new(doc, block) }

    context "when the content block is in a paragraph" do
      let(:css_selector) { ".content-block" }
      let(:html) do
        <<~HTML
          <main>
            <h2>Heading</h2>
            <p>Previous</p>
            <p><span class="content-block">Embed</span></p>
            <p>Next</p>
            <p>After next</p>
          </main>
        HTML
      end

      it "returns a five element window around the parent" do
        output = snippet.to_html

        expect(output).to include("<h2>Heading</h2>")
        expect(output).to include("<p>Previous</p>")
        expect(output).to include("<p><span class=\"content-block\">Embed</span></p>")
        expect(output).to include("<p>Next</p>")
        expect(output).to include("<p>After next</p>")
      end
    end

    context "when the content block is inside a list item" do
      let(:css_selector) { ".content-block" }
      let(:html) do
        <<~HTML
          <main>
            <p>Before list</p>
            <ul>
              <li>
                <div class="diff">
                  <ins><span class="content-block">Embed</span></ins>
                </div>
              </li>
              <li>Other item</li>
            </ul>
            <p>After list</p>
          </main>
        HTML
      end

      it "uses the list container as the parent" do
        output = snippet.to_html

        expect(output).to include("<ul>")
        expect(output).to include("<span class=\"content-block\">Embed</span>")
        expect(output).to include("<li>Other item</li>")
      end
    end

    context "when the content block is inside a table cell" do
      let(:css_selector) { ".content-block" }
      let(:html) do
        <<~HTML
          <main>
            <p>Before table</p>
            <table>
              <tr>
                <td><span class="content-block">Embed</span></td>
              </tr>
            </table>
            <p>After table</p>
          </main>
        HTML
      end

      it "uses the table container as the parent" do
        output = snippet.to_html

        expect(output).to include("<table>")
        expect(output).to include("<td><span class=\"content-block\">Embed</span></td>")
      end
    end
  end
end
