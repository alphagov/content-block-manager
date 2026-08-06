module V2
  class DocumentsController < ApplicationController
    def index
      @documents = V2::Document.by_most_recently_created_edition.page(1)
    end
  end
end
