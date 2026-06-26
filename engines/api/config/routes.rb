Api::Engine.routes.draw do
  get "blocks", to: "blocks#search"
  get "blocks/*embed_code/render", to: "blocks#render_block"
end
