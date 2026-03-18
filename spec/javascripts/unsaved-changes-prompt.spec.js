describe('GOVUK.Modules.UnsavedChangedPrompt', () => {
  describe('when a user changes an input', () => {
    let unsavedChangesPrompt
    let form
    let unloadEvent

    beforeEach(() => {
      form = document.createElement('form')
      unsavedChangesPrompt = new GOVUK.Modules.UnsavedChangesPrompt(form)
      unsavedChangesPrompt.init()

      window.GOVUK.triggerEvent(form, 'change')
      unloadEvent = new Event('beforeunload')
      spyOn(unloadEvent, 'preventDefault')
    })

    afterEach(() => {
      window.removeEventListener('beforeunload', unsavedChangesPrompt._unloadFn)
    })

    describe('and the user "unloads" the page', () => {
      it('should prompt the user', () => {
        window.dispatchEvent(unloadEvent)
        const showDialogToUser = unloadEvent.preventDefault

        expect(showDialogToUser).toHaveBeenCalled()
      })
    })

    describe('and the user submits the form', () => {
      it('should *NOT* prompt the user', () => {
        window.GOVUK.triggerEvent(form, 'submit')
        window.dispatchEvent(unloadEvent)
        const showDialogToUser = unloadEvent.preventDefault

        expect(showDialogToUser).not.toHaveBeenCalled()
      })
    })
  })
})
