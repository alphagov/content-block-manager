describe('GOVUK.Modules.Ga4FormSetup', function () {
  let container, form

  beforeEach(function () {
    container = document.createElement('div')
    container.setAttribute('data-ga4-section', 'Test Section')
    container.innerHTML = `
      <form action="/path" method="post" data-module="ga4-form-tracker" data-ga4-action="create" data-ga4-tool-name="Test Tool Name">
        <div class="govuk-form-group">
            <input type="text" name="field1" />
        </div>
        <div class="govuk-form-group">
            <input type="text" name="field2" />
        </div>
      </form>
    `
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
    expect(form.hasAttribute('data-ga4-form-no-answer-undefined')).toBe(true)
  })

  describe('on a form with one input', () => {
    it('does not add the `data-ga4-form-record-json` attribute on init', () => {
      container.innerHTML = `
      <form action="/path" method="post" data-module="ga4-form-tracker" data-ga4-action="create" data-ga4-tool-name="Test Tool Name">
        <div class="govuk-form-group">
            <input type="text" name="field1" />
        </div>
      </form>
      `

      const singleFieldForm = container.querySelector('form')

      const module = new window.GOVUK.Modules.Ga4FormSetup(container)
      module.init()

      expect(singleFieldForm.hasAttribute('data-ga4-form-record-json')).toBe(
        false
      )
      expect(
        singleFieldForm.hasAttribute('data-ga4-form-split-response-text')
      ).toBe(false)
    })
  })

  describe('on a form with just radio inputs', () => {
    it('does not add the `data-ga4-form-record-json` attribute on init', () => {
      container.innerHTML = `
      <form action="/path" method="post" data-module="ga4-form-tracker" data-ga4-action="create" data-ga4-tool-name="Test Tool Name">
        <div class="govuk-form-group">
          <input type="radio" name="input" value="1" />
          <input type="radio" name="input" value="2" />
          <input type="radio" name="input" value="3" />
        </div>
      </form>
      `

      const radioForm = container.querySelector('form')

      const module = new window.GOVUK.Modules.Ga4FormSetup(container)
      module.init()

      expect(radioForm.hasAttribute('data-ga4-form-record-json')).toBe(false)
      expect(radioForm.hasAttribute('data-ga4-form-split-response-text')).toBe(
        false
      )
    })
  })
})
