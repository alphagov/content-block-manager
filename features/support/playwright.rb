require "playwright/test"

# Include the Playwright matchers (https://playwright-ruby-client.vercel.app/docs/article/guides/rspec_integration) in the world
# so that we can use them in our step definitions. These are namespaced, so we can continue using the existing matchers.
# To use them, prefix them with `playwright_matchers:` e.g. `expect(element).to playwright_matchers: have_text("Hello world")`
World(playwright_matchers: Playwright::Test::Matchers)
