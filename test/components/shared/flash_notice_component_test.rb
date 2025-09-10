require "test_helper"

class Shared::FlashNoticeComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:flash) do
    {
      message: "This is a notice",
    }
  end

  it "renders a success alert with the correct message" do
    render_inline(Shared::FlashNoticeComponent.new(message: flash[:message]))
    assert_selector("div", text: "This is a notice")
  end

  it "escapes HTML tags in the flash message by default" do
    flash[:message] = "<b>This is unsafe</b>"
    render_inline(Shared::FlashNoticeComponent.new(message: flash[:message]))
    assert_selector("div", text: "<b>This is unsafe</b>")
    assert_no_selector "b"
  end

  it "allows HTML tags in the flash message when html_safe: true" do
    flash[:message] = "<b>This is a notice</b>"
    render_inline(Shared::FlashNoticeComponent.new(message: flash[:message], html_safe: true))
    assert_selector("div b", text: "This is a notice")
  end
end
