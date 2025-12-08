module FactCheckHelper
  def fact_check_url_with_token(edition)
    FactCheck::Engine.routes.url_helpers.block_url(
      host: ContentBlockManager.admin_root,
      id: edition.document.content_id_alias,
      token: edition.auth_bypass_token,
    )
  end
end
