RSpec.describe GovspeakPreviewHelper, type: :helper do
  it "should not alter urls to other sites" do
    html = govspeak_to_html("no [change](http://external.example.com/page.html)")
    expect_select_within_html(html, "a[href='http://external.example.com/page.html']", text: "change")
  end

  it "should not alter mailto urls" do
    html = govspeak_to_html("no [change](mailto:dave@example.com)")
    expect_select_within_html(html, "a[href='mailto:dave@example.com']", text: "change")
  end

  it "should not alter invalid urls" do
    html = govspeak_to_html("no [change](not a valid url)")
    expect_select_within_html(html, "a[href='not%20a%20valid%20url']", text: "change")
  end

  it "should not alter partial urls" do
    html = govspeak_to_html("no [change](http://)")
    expect_select_within_html(html, "a[href='http://']", text: "change")
  end

  it "should wrap output with a govspeak class" do
    html = govspeak_to_html("govspeak-text")
    expect_select_within_html(html, ".govspeak", text: "govspeak-text")
  end

  it "should mark the govspeak output as html safe" do
    html = govspeak_to_html("govspeak-text")
    expect(html).to be_html_safe
  end

  it "should produce UTF-8 for HTML entities" do
    html = govspeak_to_html("a ['funny'](/url) thing")
    expect_select_within_html(html, "a", text: "‘funny’")
  end

  it "does not change css class on buttons" do
    html = govspeak_to_html("{button}[Link text](https://www.gov.uk){/button}")
    expect_select_within_html(html, "a.govuk-button", text: "Link text")
  end

  it "should only extract level two headers by default" do
    text = "# Heading 1\n\n## Heading 2\n\n### Heading 3"
    headers = govspeak_headers(text)
    expect(headers).to eq([Govspeak::Header.new("Heading 2", 2, "heading-2")])
  end

  it "should extract header hierarchy from level 2+3 headings" do
    text = "# Heading 1\n\n## Heading 2a\n\n### Heading 3a\n\n### Heading 3b\n\n#### Ignored heading\n\n## Heading 2b"
    headers = govspeak_header_hierarchy(text)
    expect(headers).to eq([
      {
        header: Govspeak::Header.new("Heading 2a", 2, "heading-2a"),
        children: [
          Govspeak::Header.new("Heading 3a", 3, "heading-3a"),
          Govspeak::Header.new("Heading 3b", 3, "heading-3b"),
        ],
      },
      {
        header: Govspeak::Header.new("Heading 2b", 2, "heading-2b"),
        children: [],
      },
    ])
  end

  it "should raise exception when extracting header hierarchy with orphaned level 3 headings" do
    expect {
      govspeak_header_hierarchy("### Heading 3")
    }.to raise_error(Govspeak::OrphanedHeadingError) { |error|
      expect(error.heading).to eq("Heading 3")
    }
  end

  it "adds numbers to h2 headings" do
    input = "# main\n\n## first\n\n## second"
    output = '<div class="govspeak"><h1 id="main">main</h1> <h2 id="first"> <span class="number">1. </span>first</h2> <h2 id="second"> <span class="number">2. </span>second</h2></div>'
    expect_equivalent_html output, govspeak_to_html(input, heading_numbering: :auto).gsub(/\s+/, " ")
  end

  it "adds sub-numbers to h3 tags" do
    input = "## first\n\n### first point one\n\n### first point two\n\n## second\n\n### second point one"
    expected_output1 = '<h2 id="first"> <span class="number">1. </span>first</h2>'
    expected_output_1a = '<h3 id="first-point-one"> <span class="number">1.1 </span>first point one</h3>'
    expected_output_1b = '<h3 id="first-point-two"> <span class="number">1.2 </span>first point two</h3>'
    expected_output2 = '<h2 id="second"> <span class="number">2. </span>second</h2>'
    expected_output_2a = '<h3 id="second-point-one"> <span class="number">2.1 </span>second point one</h3>'
    actual_output = govspeak_to_html(input, heading_numbering: :auto).gsub(/\s+/, " ")
    expect(actual_output).to match(/#{expected_output1}/)
    expect(actual_output).to match(/#{expected_output_1a}/)
    expect(actual_output).to match(/#{expected_output_1b}/)
    expect(actual_output).to match(/#{expected_output2}/)
    expect(actual_output).to match(/#{expected_output_2a}/)
  end

  it "should not corrupt character encoding of numbered headings" do
    input = "# café"
    actual_output = govspeak_to_html(input, heading_numbering: :auto)
    expect(actual_output).to include("café</h1>")
  end

  it "should wrap admin output with a govspeak class" do
    html = govspeak_to_html("govspeak-text", { preview: true })
    expect_select_within_html(html, ".govspeak", text: "govspeak-text")
  end

  it "should mark the admin govspeak output as html safe" do
    html = govspeak_to_html("govspeak-text", { preview: true })
    expect(html).to be_html_safe
  end

  it "should call the embed codes helper" do
    input = "Here is some Govspeak"
    expected = "Expected output"
    expect(FindAndReplaceEmbedCodesService).to receive(:call).with(input).and_return(expected)
    govspeak_to_html(input, { preview: true })
  end

private

  def expect_select_within_html(html, selector, text: nil)
    fragment = Capybara.string(html)
    if text
      expect(fragment).to have_css(selector, text: text)
    else
      expect(fragment).to have_css(selector)
    end
  end

  def expect_equivalent_html(expected, actual)
    expect(EquivalentXml.equivalent?(expected, actual)).to be(true), "Expected\n#{actual}\n\nto equal\n\n#{expected}"
  end
end
