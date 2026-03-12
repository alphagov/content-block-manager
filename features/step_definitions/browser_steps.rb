Then("I am warned when navigating away") do
  page.driver.with_playwright_page do |pp|
    event_queue = Queue.new

    pp.on("dialog", proc { event_queue << :dialog_opened })

    pp.close(runBeforeUnload: true)

    # the "dialog" event runs asynchronously so we need to wait for it to push a result onto the queue
    result = Timeout.timeout(2) { event_queue.pop }

    expect(result).to be(:dialog_opened)
  end
end
