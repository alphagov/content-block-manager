RSpec.describe "components/pagination", type: :helper do
  it "should render component" do
    render("components/pagination")

    expect(rendered).to have_css ".app-c-pagination", count: 1
  end

  it "should render component with only items" do
    list_items = [
      {
        href: "/page/1",
      },
      {
        href: "/page/2",
      },
      {
        href: "/page/3",
      },
    ]

    render("components/pagination", {
      items: list_items,
    })

    expect(rendered).to have_css ".app-c-pagination", count: 1
    expect(rendered).to have_css ".govuk-pagination__prev", count: 0
    expect(rendered).to have_css ".govuk-pagination__next", count: 0
    expect(rendered).to have_css ".govuk-pagination__item", count: 3

    Capybara.string(rendered).all(".govuk-pagination__item .govuk-pagination__link").each_with_index do |element, index|
      item = list_items[index]
      expect(element.text).to eq((index + 1).to_s)
      expect(element["aria-label"]).to eq("Page #{index + 1}")
      expect(element["href"]).to eq(item[:href])
    end
  end

  it "should render component with current page" do
    render("components/pagination", {
      items: [
        {
          href: "/page/1",
        },
        {
          href: "/page/2",
          current: true,
        },
        {
          href: "/page/3",
        },
      ],
    })

    expect(rendered).to have_css ".app-c-pagination", count: 1
    expect(rendered).to have_css ".govuk-pagination__item", count: 3
    expect(rendered).to have_css ".govuk-pagination__item--current", count: 1
    expect(rendered).to have_css ".govuk-pagination__item--current", text: "2"
    expect(rendered).to have_css ".govuk-pagination__item--current .govuk-pagination__link" do |current_link|
      expect(current_link["aria-current"]).to eq("page")
    end
  end

  it "should render component with previous and next links" do
    render("components/pagination", {
      previous_href: "/page/1",
      next_href: "/page/3",
      items: [
        {
          href: "/page/1",
        },
        {
          href: "/page/2",
        },
        {
          href: "/page/3",
        },
      ],
    })

    expect(rendered).to have_css ".app-c-pagination", count: 1
    expect(rendered).to have_css ".govuk-pagination__item", count: 3
    expect(rendered).to have_css ".govuk-pagination__prev", count: 1
    expect(rendered).to have_css ".govuk-pagination__next", count: 1
  end

  it "should render component with only previous links" do
    render("components/pagination", {
      previous_href: "/page/1",
      items: [
        {
          href: "/page/1",
        },
        {
          href: "/page/2",
        },
        {
          href: "/page/3",
        },
      ],
    })

    expect(rendered).to have_css ".app-c-pagination", count: 1
    expect(rendered).to have_css ".govuk-pagination__item", count: 3
    expect(rendered).to have_css ".govuk-pagination__prev", count: 1
    expect(rendered).to have_css ".govuk-pagination__next", count: 0
  end

  it "should render component with only next links" do
    render("components/pagination", {
      next_href: "/page/3",
      items: [
        {
          href: "/page/1",
        },
        {
          href: "/page/2",
        },
        {
          href: "/page/3",
        },
      ],
    })

    expect(rendered).to have_css ".app-c-pagination", count: 1
    expect(rendered).to have_css ".govuk-pagination__item", count: 3
    expect(rendered).to have_css ".govuk-pagination__prev", count: 0
    expect(rendered).to have_css ".govuk-pagination__next", count: 1
  end

  it "should render component with custom labels" do
    list_items = [
      {
        label: "This is page 1.1",
        href: "/page/1.1",
      },
      {
        label: "This is page 1.2",
        href: "/page/1.2",
      },
      {
        label: "This is page 1.2",
        href: "/page/1.2",
      },
    ]

    render("components/pagination", {
      items: list_items,
    })

    expect(rendered).to have_css ".app-c-pagination", count: 1
    expect(rendered).to have_css ".govuk-pagination__item", count: 3
    expect(rendered).to have_css(".govuk-pagination__item .govuk-pagination__link")
    Capybara.string(rendered).all(".govuk-pagination__item .govuk-pagination__link").each_with_index do |element, index|
      item = list_items[index]
      expect(item[:label]).to eq(element.text)
      expect(item[:label]).to eq(element["aria-label"])
      expect(item[:href]).to eq(element["href"])
    end
  end

  it "should render component with custom aria label for pagination component" do
    render("components/pagination", {
      aria_label: "some pagination thing",
      items: [
        {
          href: "/page/1",
        },
        {
          href: "/page/2",
        },
        {
          href: "/page/3",
        },
      ],
    })

    expect(rendered).to have_css ".app-c-pagination", count: 1
    expect(rendered).to have_css ".govuk-pagination__item", count: 3
    expect(rendered).to have_css ".app-c-pagination" do |component|
      expect(component["aria-label"]).to eq("some pagination thing")
    end
  end

  it "should render component with custom aria labels for each item" do
    list_items = [
      {
        href: "/page/1.1",
        aria_label: "Page 1.1",
      },
      {
        href: "/page/2.1",
        current: true,
        aria_label: "Page 2.1",
      },
      {
        href: "/page/3.1",
        aria_label: "Page 3.1",
      },
    ]

    render("components/pagination", {
      items: list_items,
    })

    expect(rendered).to have_css ".app-c-pagination", count: 1
    expect(rendered).to have_css ".govuk-pagination__prev", count: 0
    expect(rendered).to have_css ".govuk-pagination__next", count: 0
    expect(rendered).to have_css ".govuk-pagination__item", count: 3
    expect(rendered).to have_css(".govuk-pagination__item .govuk-pagination__link")
    Capybara.string(rendered).all(".govuk-pagination__item .govuk-pagination__link").each_with_index do |element, index|
      item = list_items[index]
      expect((index + 1).to_s).to eq(element.text)
      expect(item[:aria_label]).to eq(element["aria-label"])
      expect(item[:href]).to eq(element["href"])
    end
  end

  it "should render component with ellipses items" do
    render("components/pagination", {
      items: [
        {
          href: "/page/1",
        },
        {
          ellipses: true,
        },
        {
          href: "/page/20",
        },
        {
          href: "/page/21",
        },
      ],
    })

    expect(rendered).to have_css ".app-c-pagination", count: 1
    expect(rendered).to have_css ".govuk-pagination__item", count: 4
    expect(rendered).to have_css ".govuk-pagination__item.govuk-pagination__item--ellipses", count: 1
  end
end
