RSpec.describe PaginationHelper, type: :helper do
  it "returns nil if only one page of objects" do
    expect(described_class.pagination_hash(current_page: 1, total_pages: 1, path: path_for_page(1))).to be_nil
  end

  it "it returns the correct objects when total pages are less than 5" do
    expected_hash = {
      previous_href: path_for_page(2),
      next_href: path_for_page(4),
      items: [
        {
          href: path_for_page(1),
          current: false,
        },
        {
          href: path_for_page(2),
          current: false,
        },
        {
          href: path_for_page(3),
          current: true,
        },
        {
          href: path_for_page(4),
          current: false,
        },
        {
          href: path_for_page(5),
          current: false,
        },
      ],
    }

    expect(described_class.pagination_hash(current_page: 3, total_pages: 5, path: path_for_page(3))).to eq(expected_hash)
  end

  [*1..3].each do |page|
    it "returns the correct output when the current page is #{page} of 10" do
      expected_hash = {
        previous_href: page > 1 ? path_for_page(page - 1) : nil,
        next_href: path_for_page(page + 1),
        items: [
          {
            href: path_for_page(1),
            label: "1",
            current: page == 1,
            aria_label: "Page 1",
          },
          {
            href: path_for_page(2),
            label: "2",
            current: page == 2,
            aria_label: "Page 2",
          },
          {
            href: path_for_page(3),
            label: "3",
            current: page == 3,
            aria_label: "Page 3",
          },
          {
            href: path_for_page(4),
            label: "4",
            current: false,
            aria_label: "Page 4",
          },
          {
            ellipses: true,
          },
          {
            href: path_for_page(10),
            label: "10",
            current: false,
            aria_label: "Page 10",
          },
        ],
      }

      expect(described_class.pagination_hash(current_page: page, total_pages: 10, path: path_for_page(page))).to eq(expected_hash)
    end
  end

  [*4..7].each do |page|
    it "returns the correct ouput when the current page is #{page} of 10" do
      expected_hash = {
        previous_href: path_for_page(page - 1),
        next_href: path_for_page(page + 1),
        items: [
          {
            href: path_for_page(1),
            label: "1",
            current: false,
            aria_label: "Page 1",
          },
          {
            ellipses: true,
          },
          {
            href: path_for_page(page - 1),
            label: (page - 1).to_s,
            current: false,
            aria_label: "Page #{page - 1}",
          },
          {
            href: path_for_page(page),
            label: page.to_s,
            current: true,
            aria_label: "Page #{page}",
          },
          {
            href: path_for_page(page + 1),
            label: (page + 1).to_s,
            current: false,
            aria_label: "Page #{page + 1}",
          },
          {
            ellipses: true,
          },
          {
            href: path_for_page(10),
            label: "10",
            current: false,
            aria_label: "Page 10",
          },
        ],
      }

      expect(described_class.pagination_hash(current_page: page, total_pages: 10, path: path_for_page(page))).to eq(expected_hash)
    end
  end

  [*8..10].each do |page|
    it "returns the correct output when the current page is #{page} of 10" do
      expected_hash = {
        previous_href: path_for_page(page - 1),
        next_href: page == 10 ? nil : path_for_page(page + 1),
        items: [
          {
            href: path_for_page(1),
            label: "1",
            current: false,
            aria_label: "Page 1",
          },
          {
            ellipses: true,
          },
          {
            href: path_for_page(7),
            label: "7",
            current: page == 7,
            aria_label: "Page 7",
          },
          {
            href: path_for_page(8),
            label: "8",
            current: page == 8,
            aria_label: "Page 8",
          },
          {
            href: path_for_page(9),
            label: "9",
            current: page == 9,
            aria_label: "Page 9",
          },
          {
            href: path_for_page(10),
            label: "10",
            current: page == 10,
            aria_label: "Page 10",
          },
        ],
      }

      expect(described_class.pagination_hash(current_page: page, total_pages: 10, path: path_for_page(page))).to eq(expected_hash)
    end
  end

  it "still constructs the pagination links correctly when a path with no query string params is passed in" do
    path = documents_path

    expected_hash = {
      previous_href: nil,
      next_href: path_for_page(2),
      items: [
        {
          href: path_for_page(1),
          current: true,
        },
        {
          href: path_for_page(2),
          current: false,
        },
      ],
    }

    expect(described_class.pagination_hash(current_page: 1, total_pages: 2, path:)).to eq(expected_hash)
  end

  it "still constructs the pagination links correctly when a path with no per_page query param is passed in" do
    path = documents_path(random_query_string: "random")

    expected_hash = {
      previous_href: nil,
      next_href: "#{path}&page=2",
      items: [
        {
          href: "#{path}&page=1",
          current: true,
        },
        {
          href: "#{path}&page=2",
          current: false,
        },
      ],
    }

    expect(described_class.pagination_hash(current_page: 1, total_pages: 2, path:)).to eq(expected_hash)
  end

  it "constructs the url correctly when the request has an anchor and but query strings" do
    path = "#{documents_path}#document_tab"

    expected_hash = {
      previous_href: nil,
      next_href: "#{path_for_page(2)}#document_tab",
      items: [
        {
          href: "#{path_for_page(1)}#document_tab",
          current: true,
        },
        {
          href: "#{path_for_page(2)}#document_tab",
          current: false,
        },
      ],
    }

    expect(described_class.pagination_hash(current_page: 1, total_pages: 2, path:)).to eq(expected_hash)
  end

  it "constructs the url correctly when the request has an anchor but and query strings" do
    path = "#{documents_path(random_query_string: 'random')}#document_tab"
    base_path = documents_path(random_query_string: "random")

    expected_hash = {
      previous_href: nil,
      next_href: "#{base_path}&page=2#document_tab",
      items: [
        {
          href: "#{base_path}&page=1#document_tab",
          current: true,
        },
        {
          href: "#{base_path}&page=2#document_tab",
          current: false,
        },
      ],
    }

    expect(described_class.pagination_hash(current_page: 1, total_pages: 2, path:)).to eq(expected_hash)
  end

  def path_for_page(page)
    documents_path(page:)
  end
end
