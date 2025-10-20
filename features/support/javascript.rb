Before("@javascript") do
  @js_console_messages ||= []
  Capybara.current_session.driver.with_playwright_page do |page|
    page.on("console", lambda { |msg|
      @js_console_messages << {
        type: msg.type,
        text: msg.text,
        location: msg.location,
      }
    })
  end
end
