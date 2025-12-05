describe('ReorderItems', () => {
  let fixture
  let module
  let element
  let firstFieldset
  let secondFieldset
  let thirdFieldset

  beforeEach(() => {
    fixture = document.createElement('div')
    fixture.innerHTML = `
      <div data-module="reorder-items">
        <fieldset>
          <legend>Item 1</legend>
          <input type="text" name="item-1" value="First">
          <button class="js-add-another__remove-button" type="button">Delete</button>
        </fieldset>
        <fieldset>
          <legend>Item 2</legend>
          <input type="text" name="item-2" value="Second">
          <button class="js-add-another__remove-button" type="button">Delete</button>
        </fieldset>
        <fieldset>
          <legend>Item 3</legend>
          <input type="text" name="item-3" value="Third">
          <button class="js-add-another__remove-button" type="button">Delete</button>
        </fieldset>
        <button class="js-add-another__add-button">Add another</button>
        <template>
          <fieldset>
            <legend>Template item</legend>
            <input type="text" name="item-template">
          </fieldset>
        </template>
      </div>
    `
    document.body.appendChild(fixture)

    element = fixture.querySelector('[data-module="reorder-items"]')
    module = new window.GOVUK.Modules.ReorderItems(element)
  })

  beforeEach(() => {
    module.init()
    firstFieldset = fixture.querySelectorAll('fieldset')[0]
    secondFieldset = fixture.querySelectorAll('fieldset')[1]
    thirdFieldset = fixture.querySelectorAll('fieldset')[2]
  })

  afterEach(() => {
    document.body.removeChild(fixture)
    fixture = null
    module = null
    firstFieldset = null
    secondFieldset = null
    thirdFieldset = null
  })

  const getNewOrder = () => {
    return Array.from(
      fixture.querySelectorAll('fieldset:not(template fieldset)')
    ).map((f) => f.querySelector('input').value)
  }

  it('adds move up and move down buttons to fieldsets as appropriate', () => {
    expect(
      firstFieldset.querySelector(
        '.app-c-reorder-items__button[data-action="move-up"]'
      )
    ).toBeFalsy()
    expect(
      firstFieldset.querySelector(
        '.app-c-reorder-items__button[data-action="move-down"]'
      )
    ).toBeTruthy()

    expect(
      secondFieldset.querySelector(
        '.app-c-reorder-items__button[data-action="move-up"]'
      )
    ).toBeTruthy()
    expect(
      secondFieldset.querySelector(
        '.app-c-reorder-items__button[data-action="move-down"]'
      )
    ).toBeTruthy()

    expect(
      thirdFieldset.querySelector(
        '.app-c-reorder-items__button[data-action="move-up"]'
      )
    ).toBeTruthy()
    expect(
      thirdFieldset.querySelector(
        '.app-c-reorder-items__button[data-action="move-down"]'
      )
    ).toBeFalsy()
  })

  it('allows the first item to be moved down', () => {
    const moveDownButton = firstFieldset.querySelector(
      '.app-c-reorder-items__button[data-action="move-down"]'
    )
    moveDownButton.click()

    const newOrder = getNewOrder()

    expect(newOrder[0]).toBe('Second')
    expect(newOrder[1]).toBe('First')
    expect(newOrder[2]).toBe('Third')
  })

  it('allows the second item to be moved up', () => {
    const moveUpButton = secondFieldset.querySelector(
      '.app-c-reorder-items__button[data-action="move-up"]'
    )
    moveUpButton.click()

    const newOrder = getNewOrder()

    expect(newOrder[0]).toBe('Second')
    expect(newOrder[1]).toBe('First')
    expect(newOrder[2]).toBe('Third')
  })

  it('allows the second item to be moved down', () => {
    const moveDownButton = secondFieldset.querySelector(
      '.app-c-reorder-items__button[data-action="move-down"]'
    )
    moveDownButton.click()

    const newOrder = getNewOrder()

    expect(newOrder[0]).toBe('First')
    expect(newOrder[1]).toBe('Third')
    expect(newOrder[2]).toBe('Second')
  })

  it('allows the third item to be moved up', () => {
    const moveUpButton = thirdFieldset.querySelector(
      '.app-c-reorder-items__button[data-action="move-up"]'
    )
    moveUpButton.click()

    const newOrder = getNewOrder()

    expect(newOrder[0]).toBe('First')
    expect(newOrder[1]).toBe('Third')
    expect(newOrder[2]).toBe('Second')
  })

  it('removes all existing reorder buttons before reinitializing', () => {
    const addAnotherButton = fixture.querySelector(
      '.js-add-another__add-button'
    )
    const initialButtons = Array.from(
      fixture.querySelectorAll('.app-c-reorder-items__button')
    )

    initialButtons.forEach((button) => {
      spyOn(button, 'remove').and.callThrough()
    })

    addAnotherButton.click()

    initialButtons.forEach((button) => {
      expect(button.remove).toHaveBeenCalled()
    })
  })

  it('reinitializes ReorderItems when add another button is clicked', () => {
    const addAnotherButton = fixture.querySelector(
      '.js-add-another__add-button'
    )

    spyOn(window.GOVUK.Modules, 'ReorderItems').and.callThrough()

    addAnotherButton.click()

    expect(window.GOVUK.Modules.ReorderItems).toHaveBeenCalledWith(element)
  })

  it('reinitializes ReorderItems when the remove button is clicked', () => {
    const addAnotherButton = fixture.querySelector(
      '.js-add-another__remove-button'
    )

    spyOn(window.GOVUK.Modules, 'ReorderItems').and.callThrough()

    addAnotherButton.click()

    expect(window.GOVUK.Modules.ReorderItems).toHaveBeenCalledWith(element)
  })
})
