class FactCheck::BlocksController < FactCheck::ApplicationController
  def show
    @block = ContentBlock.from_content_id_alias(params[:id])
  end
end
