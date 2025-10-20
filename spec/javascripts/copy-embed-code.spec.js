describe('GOVUK.Modules.CopyEmbedCode', function () {
  let fixture,
    embedCode,
    copyEmbedCode,
    copyLink,
    fakeTextarea,
    embedCodeDetails

  beforeEach(function () {
    embedCode = '{embed:content_block_contact:block-name}'
    embedCodeDetails = 'block/field-name'
    fixture = document.createElement('div')
    fixture.setAttribute('data-embed-code', embedCode)
    fixture.setAttribute('data-embed-code-details', embedCodeDetails)
    fixture.innerHTML = `
      <p class="app-c-content-block-manager-default-block__embed_code">
        {{embed:content_block_contact:block-name}}
      </p>
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
      expect(copyLink.textContent).toBe('Copy code for block/field-name')
    })

    it('should include some visually hidden field details in the "Copy code" link', function () {
      const hiddenLinkDetails = copyLink.querySelector(
        'span.govuk-visually-hidden'
      )
      expect(hiddenLinkDetails.textContent).toBe(' for block/field-name')
    })

    describe('removing visible embed codes which are required for non-JS users', function () {
      it('should remove the visible codes from the embedded objects', function () {
        const ele = fixture.querySelector(
          '.app-c-embedded-objects-blocks-component__embed-code'
        )
        expect(ele).not.toEqual(jasmine.anything())
      })

      it('should remove the visible code from the the default block', function () {
        const ele = fixture.querySelector(
          '.app-c-content-block-manager-default-block__embed_code'
        )
        expect(ele).not.toEqual(jasmine.anything())
      })
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

    it('changes and restores the link text, ignoring the visually hidden details', async function () {
      jasmine.clock().install()

      await window.GOVUK.triggerEvent(copyLink, 'click')

      copyLink = document.querySelector('.govuk-link__copy-link')
      const visibleLinkText = copyLink.querySelector('.link-text')
      const hiddenLinkText = copyLink.querySelector('.govuk-visually-hidden')

      expect(visibleLinkText.textContent).toEqual('Code copied')
      expect(hiddenLinkText.textContent).toEqual(' for block/field-name')

      jasmine.clock().tick(2000)

      expect(visibleLinkText.textContent).toEqual('Copy code')
      expect(hiddenLinkText.textContent).toEqual(' for block/field-name')

      jasmine.clock().uninstall()
    })

    it('adds "embedCodeFlash" element, then removes after interval', async function () {
      jasmine.clock().install()
      await window.GOVUK.triggerEvent(copyLink, 'click')

      const now = fixture.querySelector('.embed-code-flash')
      expect(now.textContent).toEqual(embedCode)

      jasmine.clock().tick(2000)

      const later = document.querySelector('.embed-code-flash')
      expect(later).not.toEqual(jasmine.anything())

      jasmine.clock().uninstall()
    })
  })
})
