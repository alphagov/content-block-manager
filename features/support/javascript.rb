Before("@javascript") do
  @js_console_messages ||= []
  Capybara.current_session.driver.with_playwright_page do |page|
    page.route("**/*googletagmanager.com**", lambda { |route, _|
      route.fulfill(status: 200, body: "", contentType: "application/javascript")
    })

    page.on("console", lambda { |msg|
      @js_console_messages << {
        type: msg.type,
        text: msg.text,
        location: msg.location,
      }
    })
  end
end
