'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function Ga4FormSetup(module) {
    this.forms = module.querySelectorAll(
      'form[data-module~="ga4-form-tracker"]'
    )
    this.section = module.getAttribute('data-ga4-section')
  }

  Ga4FormSetup.prototype.init = function () {
    this.forms.forEach(function (form) {
      const action = form.getAttribute('data-ga4-action')
      const toolName = form.getAttribute('data-ga4-tool-name')

      const eventData = {
        type: `Content block ${action}`,
        tool_name: toolName,
        event_name: 'form_response',
        section: this.section
      }

      form.setAttribute('data-ga4-form', JSON.stringify(eventData))

      // Set options as outlined in https://docs.publishing.service.gov.uk/repos/govuk_publishing_components/analytics-ga4/trackers/ga4-form-tracker.html#options-for-text-field
      if (form.querySelectorAll('.govuk-form-group').length > 1) {
        // only record JSON if number of fields larger than 1
        form.setAttribute('data-ga4-form-record-json', '')
        form.setAttribute('data-ga4-form-split-response-text', '')
      }

      form.setAttribute('data-ga4-form-include-text', '')
      // This ensures any empty fields are sent to GA4 as `undefined` instead of "No Answer Given"
      form.setAttribute('data-ga4-form-no-answer-undefined', '')
    }, this)
  }

  Modules.Ga4FormSetup = Ga4FormSetup
})(window.GOVUK.Modules)
