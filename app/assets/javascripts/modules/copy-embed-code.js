'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function CopyEmbedCode(module) {
    this.module = module
    this.copyLink = this.createLink.bind(this)()
    this.embedCodeFlash = this.createEmbedCodeFlash.bind(this)()
  }

  CopyEmbedCode.prototype.init = function () {
    const dd = document.createElement('dd')
    dd.classList.add('govuk-summary-list__actions')
    dd.append(this.copyLink)

    this.module.append(dd)
    this.module.classList.remove('govuk-summary-list__row--no-actions')
    this.removeVisibleCodesRequiredOnlyIfJsDisabled()
  }

  CopyEmbedCode.prototype.createLink = function () {
    const copyLink = document.createElement('a')
    copyLink.classList.add('govuk-link')
    copyLink.classList.add('govuk-link__copy-link')
    copyLink.setAttribute('href', '#')
    copyLink.setAttribute('role', 'button')
    copyLink.textContent = 'Copy code'
    copyLink.addEventListener('click', this.copyCode.bind(this))
    // Handle when a keyboard user highlights the link and clicks return
    copyLink.addEventListener(
      'keydown',
      function (e) {
        if (e.keyCode === 13) {
          this.copyCode.bind(this)
        }
      }.bind(this)
    )

    return copyLink
  }

  CopyEmbedCode.prototype.createEmbedCodeFlash = function () {
    const embedCodeFlash = document.createElement('div')
    embedCodeFlash.textContent = this.module.dataset.embedCode
    embedCodeFlash.classList.add('embed-code-flash')

    return embedCodeFlash
  }

  CopyEmbedCode.prototype.copyCode = function (e) {
    e.preventDefault()

    this.showEmbedCode(this.embedCodeFlash, this.module).then(
      this.removeEmbedCodeAfterInterval.bind(this)
    )

    const embedCode = this.module.dataset.embedCode
    this.writeToClipboard(embedCode).then(this.copySuccess.bind(this))
  }

  CopyEmbedCode.prototype.showEmbedCode = function (ele, target) {
    return new Promise(function (resolve) {
      target.querySelector('.govuk-link__copy-link').after(ele)

      resolve()
    })
  }

  CopyEmbedCode.prototype.removeEmbedCodeAfterInterval = function () {
    setTimeout(() => {
      this.embedCodeFlash.remove()
    }, 2000)
  }

  CopyEmbedCode.prototype.copySuccess = function () {
    const originalText = this.copyLink.textContent
    this.copyLink.textContent = 'Code copied'
    this.copyLink.focus()

    setTimeout(this.restoreText.bind(this, originalText), 2000)
  }

  CopyEmbedCode.prototype.restoreText = function (originalText) {
    this.copyLink.textContent = originalText
  }

  // This is a fallback for browsers that do not support the async clipboard API
  CopyEmbedCode.prototype.writeToClipboard = function (embedCode) {
    return new Promise(function (resolve) {
      // Create a textarea element with the embed code
      const textArea = document.createElement('textarea')
      textArea.value = embedCode

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

  CopyEmbedCode.prototype.removeVisibleCodesRequiredOnlyIfJsDisabled =
    function () {
      this.module
        .querySelectorAll(
          '.app-c-embedded-objects-blocks-component__embed-code'
        )
        .forEach((element) => {
          element.remove()
        })
    }

  Modules.CopyEmbedCode = CopyEmbedCode
})(window.GOVUK.Modules)
