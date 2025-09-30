describe('GOVUK.Modules.CopyEmbedCode', function () {
  let fixture, embedCode, copyEmbedCode, copyLink, fakeTextarea

  beforeEach(function () {
    embedCode = '{embed:content_block_contact:block-name}'
    fixture = document.createElement('div')
    fixture.setAttribute('data-embed-code', embedCode)
    fixture.innerHTML = `
      <dt class="govuk-summary-list__value">
        <div class="app-c-embedded-objects-blocks-component__content">
          <div data-embed-code="{{embed:content_block_contact:block-name}}">
            My block content
          </div>
        </div>
        <p class="app-c-embedded-objects-blocks-component__embed-code">
          {{embed:content_block_contact:block-name}}
        </p>
      </dt>
    `
    document.body.append(fixture)

    copyEmbedCode = new GOVUK.Modules.CopyEmbedCode(fixture)
    copyEmbedCode.init()

    copyLink = document.querySelector('.govuk-link__copy-link')

    fakeTextarea = document.createElement('textarea')
    spyOn(document, 'createElement').and.returnValue(fakeTextarea)
  })

  afterEach(function () {
    fixture.innerHTML = ''
  })

  describe('on initialisation', function () {
    it('should add a link to copy the embed code', function () {
      expect(copyLink).toBeTruthy()
      expect(copyLink.textContent).toBe('Copy code')
    })

    it('should remove the visible embed codes which are required for non-JS users', function () {
      const ele = fixture.querySelector(
        '.app-c-embedded-objects-blocks-component__embed-code'
      )
      expect(ele).not.toEqual(jasmine.anything())
    })
  })

  describe('when the "Copy code" link is clicked', function () {
    it('should create and populate a textarea', function () {
      window.GOVUK.triggerEvent(copyLink, 'click')

      expect(fakeTextarea.value).toEqual(embedCode)
    })

    it('should select the text in the textarea and run the copy command', function () {
      const copySpy = spyOn(document, 'execCommand')
      const selectSpy = spyOn(fakeTextarea, 'select')

      window.GOVUK.triggerEvent(copyLink, 'click')

      expect(selectSpy).toHaveBeenCalled()
      expect(copySpy).toHaveBeenCalled()
    })

    it('should add and remove the textarea', function () {
      const appendSpy = spyOn(document.body, 'appendChild')
      const removeSpy = spyOn(document.body, 'removeChild')

      window.GOVUK.triggerEvent(copyLink, 'click')

      expect(appendSpy).toHaveBeenCalled()
      expect(removeSpy).toHaveBeenCalled()
    })

    it('changes and restores the link text', async function () {
      jasmine.clock().install()

      await window.GOVUK.triggerEvent(copyLink, 'click')

      copyLink = document.querySelector('.govuk-link__copy-link')

      expect(copyLink.textContent).toEqual('Code copied')
      jasmine.clock().tick(2000)

      expect(copyLink.textContent).toEqual('Copy code')

      jasmine.clock().uninstall()
    })
  })
})
