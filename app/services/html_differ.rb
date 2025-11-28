class HtmlDiffer
  def initialize(before_html, after_html)
    @before = Nokogiri::HTML.fragment(before_html)
    @after = Nokogiri::HTML.fragment(after_html)
  end

  def generate_diff
    result = @after.dup

    before_texts = collect_text_nodes(@before)
    after_texts = collect_text_nodes(result)

    after_texts.each_with_index do |after_node, index|
      before_node = before_texts[index]

      next unless before_node
      next if before_node.content.strip == after_node.content.strip

      replace_with_diff(after_node, before_node.content, after_node.content)
    end

    wrap_with_styles(result.to_html)
  end

  private

  def collect_text_nodes(doc)
    nodes = []
    doc.traverse do |node|
      nodes << node if node.text? && !node.content.strip.empty?
    end
    nodes
  end

  def replace_with_diff(node, old_content, new_content)
    diff = Diffy::Diff.new(old_content, new_content, context: 0)
    node.replace(diff.to_s(:html_simple))
  end

  def wrap_with_styles(html)
    <<~HTML
      <style>
        .diff {
    border: 1px solid govuk-colour("light-grey");
    border-left: 40px solid govuk-colour("light-grey");
    padding: 15px;

    ul {
      padding-left: 0;

      li {
        margin: 0 -15px;
        padding: 0 15px;
        word-wrap: break-word;
        list-style: none;
        position: relative;

        &::after {
          content: ".";
          visibility: hidden;
        }

        del,
        ins {
          text-decoration: none;
        }
      }

      li.del,
      li.ins {
        padding-top: 2px;
      }

      li.del {
        background-color: #fadede;
        padding-bottom: 2px;

        strong {
          font-weight: normal;
          background-color: #f3aeac;
          border-bottom: 2px dashed govuk-colour("black");
        }
      }

      li.ins {
        background-color: #e6fff3;
        padding-bottom: 2px;

        strong {
          font-weight: normal;
          background-color: #99ffcf;
          border-bottom: 2px dashed govuk-colour("black");
        }
      }

      li.del::before,
      li.ins::before {
        position: absolute;
        margin-left: -55px;
        width: 40px;
        text-align: center;
        top: 0;
        bottom: 0;
      }

      li.del::before {
        color: $govuk-text-colour;
        background-color: #f3aeac;
        content: "−";
      }

      li.ins::before {
        color: $govuk-text-colour;
        background-color: #99ffcf;
        content: "+";
      }
    }
  }
      </style>
      <div class="diff-container">
        #{html}
      </div>
    HTML
  end
end
