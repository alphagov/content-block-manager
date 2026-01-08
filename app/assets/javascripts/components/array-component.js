'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function ArrayComponent(module) {
    this.module = module
  }

  ArrayComponent.prototype.init = function () {
    this.buttons = this.module.querySelectorAll('button[name="add_another"]')
    this.buttons.forEach((button) => {
      button.addEventListener('click', this.submitForm.bind(this))
    })

  }

  ArrayComponent.prototype.submitForm = function (event) {
    const form = event.target.form
    const frameId = event.target.dataset.frameId
    const frame = document.getElementById(frameId)

    form.dataset.turbo = 'true'
    form.dataset.turboFrame = frameId

    form.addEventListener(
      'turbo:submit-end',
      function () {
        form.dataset.turbo = 'false'
      },
      { once: true }
    )

  }

  Modules.ArrayComponent = ArrayComponent
})(window.GOVUK.Modules)
