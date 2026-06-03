Api::Engine.routes.draw do
  get "blocks/search", to: "blocks#search"
  get "blocks/render", to: "blocks#_render"
end
