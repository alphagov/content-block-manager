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

      form.setAttribute('data-ga4-form-record-json', '')
      form.setAttribute('data-ga4-form-split-response-text', '')
      form.setAttribute('data-ga4-form-include-text', '')
    }, this)
  }

  Modules.Ga4FormSetup = Ga4FormSetup
})(window.GOVUK.Modules)
