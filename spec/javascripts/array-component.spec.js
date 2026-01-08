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

})
