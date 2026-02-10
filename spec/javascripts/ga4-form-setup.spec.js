describe('GOVUK.Modules.Ga4FormSetup', function () {
  let container, form

  beforeEach(function () {
    container = document.createElement('div')
    container.setAttribute('data-ga4-section', 'Test Section')
    container.innerHTML =
      '<form action="/path" method="post" ' +
      'data-module="ga4-form-tracker" ' +
      'data-ga4-action="create" ' +
      'data-ga4-tool-name="Test Tool Name">' +
      '</form>'

    document.body.appendChild(container)
    form = container.querySelector('form')
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('constructs the GA4 JSON object and sets attributes on the form', function () {
    const module = new window.GOVUK.Modules.Ga4FormSetup(container)
    module.init()

    const expectedJson = {
      type: 'Content block create',
      tool_name: 'Test Tool Name',
      event_name: 'form_response',
      section: 'Test Section'
    }

    expect(form.getAttribute('data-ga4-form')).toEqual(
      JSON.stringify(expectedJson)
    )
    expect(form.hasAttribute('data-ga4-form-record-json')).toBe(true)
    expect(form.hasAttribute('data-ga4-form-split-response-text')).toBe(true)
    expect(form.hasAttribute('data-ga4-form-include-text')).toBe(true)
  })
})
