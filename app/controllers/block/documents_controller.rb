module Block
  class DocumentsController < ApplicationController
    def index
      @documents = Block::Document.by_most_recently_created_edition.page(1)
    end
  end
end
