/* global describe, beforeEach, afterEach, it, expect, spyOn */

describe('GOVUK.Modules.ArrayComponent', function () {
  let form, frame, component, fixture

  beforeEach(function () {
    fixture = document.createElement('div')
    fixture.innerHTML = `
      <form id="test-form" action="/test" method="post">
        <turbo-frame id="test-frame">
          <div class="app-c-content-block-manager-array-item-component" id="item-1">
            <div class="checkbox-wrapper">
              <input type="checkbox" name="item[1][_destroy]" class="js-array-item-destroy">
            </div>
          </div>
        </turbo-frame>
        
        <div class="app-c-array-component">
          <button type="button" name="add_another" data-frame-id="test-frame">Add another</button>
        </div>
      </form>`
    document.body.append(fixture)

    form = document.getElementById('test-form')
    frame = document.getElementById('test-frame')

    component = new window.GOVUK.Modules.ArrayComponent(fixture)
  })

  afterEach(function () {
    fixture.innerHTML = ''
  })

  describe('clicking "Add another" (Turbo integration)', function () {
    let addButton

    beforeEach(function () {
      component.init()
      addButton = document.querySelector('button[name="add_another"]')
    })

    it('sets dataset.turbo and turboFrame on the form', function () {
      addButton.click()
      expect(form.dataset.turbo).toEqual('true')
      expect(form.dataset.turboFrame).toEqual('test-frame')
    })

    it('resets dataset.turbo to false after turbo:submit-end', function () {
      addButton.click()

      const event = new window.Event('turbo:submit-end', { bubbles: true })
      form.dispatchEvent(event)

      expect(form.dataset.turbo).toEqual('false')
    })

    it('re-initializes the component when the turbo frame renders', function () {
      spyOn(component, 'init').and.callThrough()

      addButton.click()

      // Simulate new content arriving (Turbo Frame Render)
      const newItemHtml = `
        <div class="app-c-content-block-manager-array-item-component" id="item-2">
          <div class="checkbox-wrapper">
            <input type="checkbox" name="item[2][_destroy]" class="js-array-item-destroy">
          </div>
        </div>`
      frame.innerHTML += newItemHtml

      const event = new window.Event('turbo:frame-render', { bubbles: true })
      frame.dispatchEvent(event)

      expect(component.init).toHaveBeenCalledTimes(1)

      const newButton = frame.querySelector(
        '#item-2 .js-array-item-delete-button'
      )
      expect(newButton).not.toBeNull()
    })

    it('reinitializes all GOV.UK components within the frame', function () {
      spyOn(GOVUK.modules, 'start').and.callThrough()

      addButton.click()

      const event = new window.Event('turbo:frame-render', { bubbles: true })
      frame.dispatchEvent(event)

      expect(GOVUK.modules.start).toHaveBeenCalledWith(event.target)
    })
  })

  describe('initialization', function () {
    it('creates a "Remove" button for existing delete checkboxes', function () {
      component.init()
      const deleteButton = document.querySelector(
        '.js-array-item-delete-button'
      )
      expect(deleteButton).not.toBeNull()
      expect(deleteButton.innerHTML).toEqual('Remove')
      expect(deleteButton.classList).toContain('govuk-button--warning')
    })

    it('hides the original delete checkbox', function () {
      component.init()
      const checkbox = document.querySelector('.js-array-item-destroy')
      expect(checkbox.classList).toContain('govuk-visually-hidden')
    })

    it('does not create duplicate buttons if init is called twice', function () {
      component.init()
      component.init()
      const buttons = document.querySelectorAll('.js-array-item-delete-button')
      expect(buttons.length).toEqual(1)
    })
  })

  describe('clicking the "Remove" button', function () {
    it('removes the entire item component from the DOM', function () {
      component.init()

      const item = document.getElementById('item-1')
      const deleteButton = document.querySelector(
        '.js-array-item-delete-button'
      )

      expect(document.body.contains(item)).toBe(true)

      deleteButton.click()

      expect(document.body.contains(item)).toBe(false)
    })
  })
})
