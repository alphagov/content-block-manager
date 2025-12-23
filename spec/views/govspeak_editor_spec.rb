RSpec.describe "components/govspeak_editor", type: :view do
  def render_component(locals)
    render partial: "components/govspeak_editor", locals:
  end

  it "errors when no parameters given" do
    expect {
      render_component({})
    }.to raise_error
  end

  it "renders the basic component" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
    })

    expect(rendered).to have_css ".app-c-govspeak-editor[data-module='govspeak-editor']"
    expect(rendered).not_to have_css ".govuk-label.govuk-label--s"
  end

  it "sets label to bold" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
        bold: true,
      },
    })

    expect(rendered).to have_css ".govuk-label.govuk-label--s"
  end

  it "includes hint" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
      hint: "look out",
      hint_id: "optional",
    })

    expect(rendered).to have_css ".govuk-hint[id='optional']", text: "look out"
  end

  it "can display errors" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
      error_items: [
        {
          text: "there's nothing here",
          href: "error1",
        },
        {
          text: "no really, there's nothing here",
          href: "error2",
        },
      ],
    })

    expect(rendered).to have_css ".app-c-govspeak-editor.govuk-form-group--error"
    expect(rendered).to have_css ".govuk-error-message", text: "Error: there's nothing hereno really, there's nothing here"
  end

  it "can set number of rows on the textarea" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
      rows: 2,
    })

    expect(rendered).to have_css ".govuk-textarea[rows='2']"
  end

  it "can set the textarea to right to left" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
      right_to_left: true,
    })

    expect(rendered).to have_css ".govuk-textarea[dir='rtl']"
  end

  it "accepts data attributes" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
      data_attributes: {
        some_attribute: "This is for the main component",
        module: "one-module",
      },
      textarea_data_attributes: {
        some_attribute: "This is for the textarea",
        module: "two-module",
      },
      preview_button_data_attributes: {
        some_attribute: "This is for the toggle preview button",
        module: "three-module",
      },
    })

    expect(rendered).to have_css ".app-c-govspeak-editor[data-some-attribute='This is for the main component'][data-module='one-module govspeak-editor']"
    expect(rendered).to have_css ".govuk-textarea[data-some-attribute='This is for the textarea'][data-module='two-module paste-html-to-govspeak']"
    expect(rendered).to have_css ".govuk-button[data-some-attribute='This is for the toggle preview button'][data-module='three-module']"
  end

  it "can have a value for the textarea" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
      value: "Here is some text I wrote",
    })

    expect(rendered).to have_css ".govuk-textarea", text: "Here is some text I wrote"
  end

  it "can have attachments and alternative format provider id" do
    render_component({
      name: "my-name",
      label: {
        text: "my-label",
      },
      data_attributes: {
        alternative_format_provider_id: "123",
        image_ids: [1, 2, 3],
        attachment_ids: [3, 4, 5],
      },
      value: "This is an attachment: !@1 This is an image: !!1",
    })

    expect(rendered).to have_css ".app-c-govspeak-editor[data-alternative-format-provider-id='123'][data-image-ids='[1,2,3]'][data-attachment-ids='[3,4,5]']"
    expect(rendered).to have_css ".govuk-textarea", text: "This is an attachment: !@1 This is an image: !!1"
  end
end
