Api::Engine.routes.draw do
  get "blocks", to: "blocks#search"
end
