'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function ReorderItems(module) {
    this.module = module
  }

  ReorderItems.prototype.init = function () {
    this.getFieldsets().forEach((fieldset, index) => {
      const wrapper = document.createElement('div')
      wrapper.classList.add('app-c-reorder-items__wrapper')

      this.addMoveUpButton(wrapper, index)
      this.addMoveDownButton(wrapper, index)

      fieldset.classList.add('app-c-reorder-items')
      fieldset.prepend(wrapper)
    })

    this.module.addEventListener('click', (event) => {
      if (event.target.classList.contains('app-c-reorder-items__button')) {
        this.handleButtonClick(event)
      }
    })

    const addAnotherButton = this.module.querySelector(
      '.js-add-another__add-button'
    )

    const removeButton = this.module.querySelector(
      '.js-add-another__remove-button'
    )

    // Remove the buttons and reload the module when add another button is clicked
    addAnotherButton.addEventListener('click', () => {
      this.reinitalizeModule()
    })

    // Remove the buttons and reload the module when the delete button is clicked
    removeButton.addEventListener('click', () => {
      this.reinitalizeModule()
    })
  }

  ReorderItems.prototype.reinitalizeModule = function () {
    const buttons = this.module.querySelectorAll('.app-c-reorder-items__button')
    buttons.forEach((button) => {
      button.remove()
    })
    new window.GOVUK.Modules.ReorderItems(this.module).init()
  }

  ReorderItems.prototype.addMoveUpButton = function (wrapper, index) {
    // Don't add an up button if this is the first fieldset
    if (index !== 0) {
      wrapper.innerHTML += `<button class="govuk-button gem-c-button--secondary-quiet app-c-reorder-items__button" data-action="move-up">Move up</button>`
    }
  }

  ReorderItems.prototype.addMoveDownButton = function (wrapper, index) {
    // Don't add a down button if this is the last fieldset
    if (index !== this.getFieldsets().length - 1) {
      wrapper.innerHTML += `<button class="govuk-button gem-c-button--secondary-quiet app-c-reorder-items__button" data-action="move-down">Move down</button>`
    }
  }

  ReorderItems.prototype.getFieldsets = function () {
    return this.module.querySelectorAll('fieldset:not(:last-child)')
  }

  ReorderItems.prototype.handleButtonClick = function (event) {
    event.preventDefault()
    const action = event.target.dataset.action

    const currentFieldset = event.target.closest('fieldset')
    const fieldsets = this.getFieldsets()
    const index = Array.from(fieldsets).indexOf(currentFieldset)

    const targetFieldset =
      action === 'move-up' ? fieldsets[index - 1] : fieldsets[index + 1]

    // Move the values of each input field in the current fieldset to the target fieldset
    currentFieldset
      .querySelectorAll('input[type="text"]')
      .forEach((input, i) => {
        const targetInput =
          targetFieldset.querySelectorAll('input[type="text"]')[i]
        const oldValue = input.value
        const newValue = targetInput.value

        targetInput.value = oldValue
        input.value = newValue
      })

    // Scroll the target fieldset into view and focus the first input field
    targetFieldset.scrollIntoView({ behavior: 'smooth' })
    targetFieldset
      .querySelector('input:not([type="hidden"]), select, textarea')
      .focus()
  }

  Modules.ReorderItems = ReorderItems
})(window.GOVUK.Modules)
