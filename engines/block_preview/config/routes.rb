BlockPreview::Engine.routes.draw do
  get ":host_content_id/edition/:edition_id", to: "preview#show", as: :host_content_preview
  post ":host_content_id/edition/:edition_id/form_handler", to: "preview#form_handler", as: :host_content_preview_form_handler

  get ":host_content_id/document/:document_id/", to: "dynamic_preview#show", as: :dynamic_host_content_preview
end
