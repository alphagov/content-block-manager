# rubocop:disable Lint/Debugger
When("I save and open the page") do
  save_and_open_page
end

After do |scenario|
  if scenario.failed? && ENV["DEBUG_OPEN_ON_FAILURE"] == "true"
    save_and_open_page
  end
end
# rubocop:enable Lint/Debugger
