Api::Engine.routes.draw do
  get "blocks/search", to: "blocks#blocks_search"
  get "blocks/render", to: "blocks#blocks_render"
end
