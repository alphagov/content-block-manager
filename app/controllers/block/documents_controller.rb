module Block
  class DocumentsController < ApplicationController
    def index
      @filters = params.slice(:keyword, :block_type, :lead_organisation, :page, :last_updated_to, :last_updated_from)
        .permit!
        .to_h

      @documents = Block::Document.page(1)
    end
  end
end
