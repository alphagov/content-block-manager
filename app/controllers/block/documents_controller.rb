module Block
  class DocumentsController < ApplicationController
    def index
      @editions = Block::Document.all.map { |document| document.editions.last }
    end
  end
end
