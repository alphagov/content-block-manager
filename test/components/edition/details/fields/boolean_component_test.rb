require "test_helper"

class Edition::Details::Fields::BooleanComponentTest < BaseComponentTestClass
  let(:described_class) { Edition::Details::Fields::BooleanComponent }

  let(:edition) { build(:edition, :pension) }
  let(:default_value) { nil }
  let(:field) { stub("field", name: "email_address", is_required?: true, default_value:) }
  let(:schema) { stub(:schema) }

  before do
    render_inline(
      described_class.new(
        edition:,
        field:,
        schema:,
        value: field_value,
      ),
    )
  end

  describe "when no value is given" do
    let(:field_value) { nil }

    it "should not check the checkbox" do
      assert_selector "input[type=\"checkbox\"][value=\"true\"]"
      assert_no_selector "input[type=\"checkbox\"][value=\"true\"][checked=\"checked\"]"
    end

    describe "when the default value is true" do
      let(:default_value) { "true" }

      it "should check the checkbox" do
        assert_selector "input[type=\"checkbox\"][value=\"true\"][checked=\"checked\"]"
      end
    end
  end

  describe "when the value given is 'true'" do
    let(:field_value) { "true" }

    it "should check the checkbox" do
      assert_selector "input[type=\"checkbox\"][value=\"true\"][checked=\"checked\"]"
    end
  end

  describe "when the value given is 'false'" do
    let(:field_value) { "false" }

    it "should check the checkbox" do
      assert_no_selector "input[type=\"checkbox\"][value=\"true\"][checked=\"checked\"]"
    end
  end
end
