RSpec.describe DiffHelper, type: :helper do
  describe "#render_diff" do
    let(:diff_html) { '<div class="diff">my nice diff</div>' }

    it "returns a diff of two strings" do
      expect(Nokodiff).to receive(:diff).and_return(diff_html)
      old_text = "<span>abc</span>"
      new_text = "<span>abcd</span>"

      actual_diff_html = helper.render_diff(old_text, new_text)

      expect(actual_diff_html).to eq(diff_html)
    end

    context "when given invalid HTML" do
      it "wraps the inputs in a tag to ensure Nokodiff doesn't raise an exception" do
        expect {
          helper.render_diff("foo", "bar")
        }.not_to raise_error
      end

      it "wraps the inputs in a tag to ensure Nokodiff returns a diff" do
        expect(Nokodiff).to receive(:diff).with("<span>foo</span>", "<span>bar</span>")
        helper.render_diff("foo", "bar")
      end
    end
  end
end
