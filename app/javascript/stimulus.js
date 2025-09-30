// Entry point for the build script in your package.json
import { Application } from '@hotwired/stimulus'

const application = Application.start()

// Configure Stimulus development experience
application.debug = true
window.Stimulus = application

export { application }
import './controllers/index.js'
