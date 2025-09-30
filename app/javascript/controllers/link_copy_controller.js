import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['code']
  static values = {
    code: { type: String }
  }

  connect() {
    this.setActionOnLink()
    this.hideVisibleLinkForNonJsUsers()
  }

  copy() {
    console.log("Let's copy: " + this.codeValue)
    this.displayCode()
    setTimeout(this.removeCode.bind(this), 2000)
    this.saveCodeToClipboard(this.codeValue)
  }

  copyLink() {
   return this.codeTarget.querySelectorAll(
      '.govuk-summary-list__actions a'
    )[0]
  }

  setActionOnLink() {
    if (this.copyLink() === undefined) {
      return false
    }

    this.copyLink().setAttribute('data-action', 'click->link-copy#copy')
  }

  saveCodeToClipboard(code) {
    return new Promise(function (resolve) {
      // Create a textarea element with the embed code
      const textArea = document.createElement('textarea')
      textArea.value = code

      document.body.appendChild(textArea)

      // Select the text in the textarea
      textArea.select()

      // Copy the selected text
      document.execCommand('copy')

      // Remove our textarea
      document.body.removeChild(textArea)

      resolve()
    })
  }

  displayCode() {
    const embedCodeFlash = document.createElement('div')
    embedCodeFlash.textContent = this.codeValue
    embedCodeFlash.classList.add('embed-code')

    this.copyLink().after(embedCodeFlash)
  }

  removeCode() {
    this.codeTarget.querySelectorAll('.embed-code')[0].remove()
  }

  hideVisibleLinkForNonJsUsers() {
    this.codeTarget.querySelectorAll(
      '.app-c-embedded-objects-blocks-component__embed-code'
    ).forEach((element) => {
      element.remove()
    })
  }
}
