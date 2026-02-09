class FactCheck::BlocksController < FactCheck::ApplicationController
  include ContentBlockManager::AuthenticatesWithJWT

  def show
    @block = block
    @host_content_items = HostContentItem.for_document(@block.document)
    @subschemas = SubschemaCollection.new(@block.schema.subschemas)
  end

private

  def block
    @block ||= ContentBlock.from_content_id_alias(params[:id])
  end
end
