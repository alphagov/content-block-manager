require "test_helper"

class GovspeakPreviewHelperTest < ActionView::TestCase
  test "should not alter urls to other sites" do
    html = govspeak_to_html("no [change](http://external.example.com/page.html)")
    assert_select_within_html html, "a[href=?]", "http://external.example.com/page.html", text: "change"
  end

  test "should not alter mailto urls" do
    html = govspeak_to_html("no [change](mailto:dave@example.com)")
    assert_select_within_html html, "a[href=?]", "mailto:dave@example.com", text: "change"
  end

  test "should not alter invalid urls" do
    html = govspeak_to_html("no [change](not a valid url)")
    assert_select_within_html html, "a[href=?]", "not%20a%20valid%20url", text: "change"
  end

  test "should not alter partial urls" do
    html = govspeak_to_html("no [change](http://)")
    assert_select_within_html html, "a[href=?]", "http://", text: "change"
  end

  test "should wrap output with a govspeak class" do
    html = govspeak_to_html("govspeak-text")
    assert_select_within_html html, ".govspeak", text: "govspeak-text"
  end

  test "should mark the govspeak output as html safe" do
    html = govspeak_to_html("govspeak-text")
    assert html.html_safe?
  end

  test "should produce UTF-8 for HTML entities" do
    html = govspeak_to_html("a ['funny'](/url) thing")
    assert_select_within_html html, "a", text: "‘funny’"
  end

  test "does not change css class on buttons" do
    html = govspeak_to_html("{button}[Link text](https://www.gov.uk){/button}")
    assert_select_within_html html, "a.govuk-button", "Link text"
  end

  test "should only extract level two headers by default" do
    text = "# Heading 1\n\n## Heading 2\n\n### Heading 3"
    headers = govspeak_headers(text)
    assert_equal [Govspeak::Header.new("Heading 2", 2, "heading-2")], headers
  end

  test "should extract header hierarchy from level 2+3 headings" do
    text = "# Heading 1\n\n## Heading 2a\n\n### Heading 3a\n\n### Heading 3b\n\n#### Ignored heading\n\n## Heading 2b"
    headers = govspeak_header_hierarchy(text)
    assert_equal [
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
    ],
                 headers
  end

  test "should raise exception when extracting header hierarchy with orphaned level 3 headings" do
    e = assert_raise(Govspeak::OrphanedHeadingError) { govspeak_header_hierarchy("### Heading 3") }
    assert_equal "Heading 3", e.heading
  end

  test "adds numbers to h2 headings" do
    input = "# main\n\n## first\n\n## second"
    output = '<div class="govspeak"><h1 id="main">main</h1> <h2 id="first"> <span class="number">1. </span>first</h2> <h2 id="second"> <span class="number">2. </span>second</h2></div>'
    assert_equivalent_html output, govspeak_to_html(input, heading_numbering: :auto).gsub(/\s+/, " ")
  end

  test "adds sub-numbers to h3 tags" do
    input = "## first\n\n### first point one\n\n### first point two\n\n## second\n\n### second point one"
    expected_output1 = '<h2 id="first"> <span class="number">1. </span>first</h2>'
    expected_output_1a = '<h3 id="first-point-one"> <span class="number">1.1 </span>first point one</h3>'
    expected_output_1b = '<h3 id="first-point-two"> <span class="number">1.2 </span>first point two</h3>'
    expected_output2 = '<h2 id="second"> <span class="number">2. </span>second</h2>'
    expected_output_2a = '<h3 id="second-point-one"> <span class="number">2.1 </span>second point one</h3>'
    actual_output = govspeak_to_html(input, heading_numbering: :auto).gsub(/\s+/, " ")
    assert_match %r{#{expected_output1}}, actual_output
    assert_match %r{#{expected_output_1a}}, actual_output
    assert_match %r{#{expected_output_1b}}, actual_output
    assert_match %r{#{expected_output2}}, actual_output
    assert_match %r{#{expected_output_2a}}, actual_output
  end

  test "should not corrupt character encoding of numbered headings" do
    input = "# café"
    actual_output = govspeak_to_html(input, heading_numbering: :auto)
    assert actual_output.include?("café</h1>")
  end

  test "should wrap admin output with a govspeak class" do
    html = govspeak_to_html("govspeak-text", { preview: true })
    assert_select_within_html html, ".govspeak", text: "govspeak-text"
  end

  test "should mark the admin govspeak output as html safe" do
    html = govspeak_to_html("govspeak-text", { preview: true })
    assert html.html_safe?
  end

  test "should call the embed codes helper" do
    input = "Here is some Govspeak"
    expected = "Expected output"
    FindAndReplaceEmbedCodesService.expects(:call).with(input).returns(expected)
    govspeak_to_html(input, { preview: true })
  end

private

  def collapse_whitespace(string)
    string.gsub(/\s+/, " ").strip
  end
end
