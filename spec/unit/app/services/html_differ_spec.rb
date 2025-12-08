RSpec.describe HtmlDiffer do
  describe "#generate_diff" do
    context "when HTML is identical" do
      let(:before_html) { "<p>Title: example</p>" }
      let(:after_html) { "<p>Title: example</p>" }

      it "returns the original HTML" do
        differ = HtmlDiffer.new(before_html, after_html)
        output = differ.generate_diff

        expect(output).to include("<p>Title: example</p>")
        expect(output).not_to include("<del>")
        expect(output).not_to include("<ins>")
      end
    end

    context "when flat text" do
      describe "is unchanged" do
        let(:before_html) { "<p>Title: example</p>" }
        let(:after_html) { "<p>Title: example</p>" }

        it "returns the comparison of the unchanged HTML text" do
          differ = HtmlDiffer.new(before_html, after_html)
          output = differ.generate_diff

          expect(output).not_to include('<div class="diff">')
          expect(output).to include("<p>Title: example</p>")

          expect(output).not_to include('<li class="del">')
          expect(output).not_to include('<li class="ins">')
        end
      end

      describe "changes at the end of a sentence" do
        let(:before_html) { "<p>Title: example</p>" }
        let(:after_html) { "<p>Title: new text</p>" }

        it "returns the comparison of the changed HTML text" do
          differ = HtmlDiffer.new(before_html, after_html)
          output = differ.generate_diff

          expect(output).to include('<div class="diff">')
          expect(output).to include("<del>Title: <strong>example</strong></del>")
          expect(output).to include("<ins>Title: <strong>new text</strong></ins>")

          expect(output).to include('<li class="del">')
          expect(output).to include('<li class="ins">')
        end
      end

      describe "changes in the middle of a sentence" do
        let(:before_html) { "<p>Monday to Friday, 9am to midday and 2pm to 4:30pm (closed on bank holidays)</p>" }
        let(:after_html) { "<p>Monday to Friday, 9am to midday (closed on bank holidays)</p>" }

        it "returns the comparison of the changed HTML text" do
          differ = HtmlDiffer.new(before_html, after_html)
          output = differ.generate_diff

          expect(output).to include('<div class="diff">')
          expect(output).to include('<li class="del"><del>Monday to Friday, 9am to midday <strong>and 2pm to 4:30pm </strong>(closed on bank holidays)</del></li>')
          expect(output).to include(' <li class="ins"><ins>Monday to Friday, 9am to midday (closed on bank holidays)</ins></li>')

          expect(output).to include('<li class="del">')
          expect(output).to include('<li class="ins">')
        end
      end
    end

    context "links" do
      it "diffs changed link text" do
        before_html = <<-HTML
          <div>
            <p><strong>Example links:</strong></p>
              <ul>
                <li><a href="https://a.example.com">Link A</a></li>
              </ul>
          </div>
        HTML

        after_html = <<-HTML
          <div>
            <p><strong>Example links:</strong></p>
              <ul>
                <li><a href="https://a.example.com">Link B</a></li>
              </ul>
          </div>
        HTML

        differ = HtmlDiffer.new(before_html, after_html)
        output = differ.generate_diff

        expect(output).to include("<del>Link <strong>A</strong></del>")
        expect(output).not_to include("<del>Link <strong>B</strong></del>")
        expect(output).to include("<ins>Link <strong>B</strong></ins>")
      end

      it "diffs a removed link against the matching line" do
        before_html = <<-HTML
          <div>
            <p><strong>Example links:</strong></p>
              <ul>
                <li><a href="https://a.example.com">Link A</a></li>
                <li><a href="https://b.example.com">Link B</a></li>
              </ul>
          </div>
        HTML

        after_html = <<-HTML
          <div>
            <p><strong>Example links:</strong></p>
              <ul>
                <li><a href="https://b.example.com">Link B</a></li>
              </ul>
          </div>
        HTML

        differ = HtmlDiffer.new(before_html, after_html)
        output = differ.generate_diff

        expect(output).to include("<del>Link A</del>")
        expect(output).not_to include("<del>Link B</del>")
        expect(output).not_to include("<ins>Link B</ins>")
        expect(output).to include(">Link B</a>")
      end
    end
  end
end
