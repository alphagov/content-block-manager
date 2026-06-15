'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.vars = window.GOVUK.vars || {}
window.GOVUK.vars.extraDomains = [
  {
    name: 'production',
    domains: ['content-block-manager.publishing.service.gov.uk'],
    initialiseGA4: true,
    id: 'GTM-KHZP7S7Q',
    gaProperty: 'G-X4BPTC5NQW'
  },
  {
    name: 'staging',
    domains: ['content-block-manager.staging.publishing.service.gov.uk'],
    initialiseGA4: false
  },
  {
    name: 'integration',
    domains: ['content-block-manager.integration.publishing.service.gov.uk'],
    initialiseGA4: true,
    id: 'GTM-KHZP7S7Q',
    gaProperty: 'G-9FZ6YBQ08M',
    auth: 'GoGeIsCL2PK9Dv50tgM6Lg',
    preview: 'env-172'
  }
]
