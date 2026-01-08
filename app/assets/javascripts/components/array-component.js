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

    this.initializeDeleteButtons()
  }

  ArrayComponent.prototype.initializeDeleteButtons = function () {
    const deleteCheckboxes = this.module.querySelectorAll(
      '.js-array-item-destroy'
    )
    deleteCheckboxes.forEach((checkbox) => {
      checkbox.classList.add('govuk-visually-hidden')
      if (!checkbox.parentNode.querySelector('.js-array-item-delete-button')) {
        const deleteButton = document.createElement('button')
        deleteButton.innerHTML = 'Remove'
        deleteButton.classList.add(
          'govuk-button',
          'govuk-button--warning',
          'js-array-item-delete-button'
        )
        checkbox.parentNode.appendChild(deleteButton)
        deleteButton.addEventListener('click', this.destroyItem.bind(this))
      }
    })
  }

  ArrayComponent.prototype.destroyItem = function (event) {
    event.preventDefault()
    event.target
      .closest('.app-c-content-block-manager-array-item-component')
      .remove()
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

    frame.addEventListener(
      'turbo:frame-render',
      function () {
        this.init()
      }.bind(this)
    )
  }

  Modules.ArrayComponent = ArrayComponent
})(window.GOVUK.Modules)
