RSpec.describe Shared::FlashSuccessComponent, type: :component do
  let(:flash) do
    {
      message: "This is a notice",
    }
  end

  it "renders a success alert with the correct message" do
    render_inline(described_class.new(message: flash[:message]))

    expect(page).to have_css "div", text: "This is a notice"
  end

  it "escapes HTML tags in the flash message by default" do
    flash[:message] = "<b>This is unsafe</b>"
    render_inline(described_class.new(message: flash[:message]))

    expect(page).to have_css "div", text: "<b>This is unsafe</b>"
    expect(page).to_not have_css "b"
  end

  it "allows HTML tags in the flash message when html_safe: true" do
    flash[:message] = "<b>This is a notice</b>"
    render_inline(described_class.new(message: flash[:message], html_safe: true))

    expect(page).to have_css "div b", text: "This is a notice"
  end
end
