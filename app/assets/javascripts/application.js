//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/components/accordion
//= require govuk_publishing_components/components/add-another
//= require govuk_publishing_components/components/checkboxes
//= require govuk_publishing_components/components/copy-to-clipboard
//= require govuk_publishing_components/components/govspeak
//= require govuk_publishing_components/components/select-with-search
//= require govuk_publishing_components/components/tabs
//= require govuk_publishing_components/lib/cookie-functions
//= require govuk_publishing_components/lib/trigger-event

//= require components/govspeak-editor

//= require ./modules/auto-populate-telephone-number-label
//= require ./modules/copy-embed-code

'use strict'
window.GOVUK.approveAllCookieTypes()
window.GOVUK.cookie('cookies_preferences_set', 'true', { days: 365 })
