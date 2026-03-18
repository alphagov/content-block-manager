window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function UnsavedChangesPrompt($module) {
    this.form = $module
  }

  UnsavedChangesPrompt.prototype.init = function () {
    this.formSubmit = false
    this.userChange = false

    this._unloadFn = this._unloadFn.bind(this)

    this.handleChanges()
    this.handleUnload()
  }

  UnsavedChangesPrompt.prototype.handleChanges = function () {
    this.form.addEventListener(
      'submit',
      function () {
        this.formSubmit = true
      }.bind(this)
    )

    this.form.addEventListener(
      'change',
      function () {
        this.userChange = true
      }.bind(this)
    )
  }

  UnsavedChangesPrompt.prototype.handleUnload = function () {
    window.addEventListener('beforeunload', this._unloadFn)
  }

  UnsavedChangesPrompt.prototype._unloadFn = function (e) {
    if (this.userChange && !this.formSubmit) {
      e.preventDefault()
    }
  }

  Modules.UnsavedChangesPrompt = UnsavedChangesPrompt
})(window.GOVUK.Modules)
