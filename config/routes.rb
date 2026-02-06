require "govuk_sidekiq/gds_sso_middleware"

Rails.application.routes.draw do
  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response
  mount Flipflop::Engine => "/flipflop"
  mount FactCheck::Engine => "/fact-check"
  mount BlockPreview::Engine => "/preview"
  mount GovukSidekiq::GdsSsoMiddleware, at: "/sidekiq"

  scope via: :all do
    match "/400", to: "errors#bad_request"
    match "/403", to: "errors#forbidden"
    match "/404", to: "errors#not_found"
    match "/422", to: "errors#unprocessable_content"
    match "/500", to: "errors#internal_server_error"
  end

  namespace :admin do
    post "preview" => "preview#preview"
  end

  root to: "documents#index", via: :get

  resources :users, only: %i[show]

  get "content-id/:content_id", to: "documents#content_id", as: :content_id
  resources :documents, only: %i[index show new], path_names: { new: "(:block_type)/new" }, path: "" do
    collection do
      post :new_document_options_redirect
    end

    member do
      get "published_edition", to: "published_edition#show"
    end

    resources :editions, only: %i[new create]
    get "schedule/edit", to: "documents/schedule#edit", as: :schedule_edit
    put "schedule", to: "documents/schedule#update", as: :update_schedule
    patch "schedule", to: "documents/schedule#update"
  end
  resources :editions, only: %i[new create destroy], path_names: { new: ":block_type/new" } do
    member do
      get :preview, to: "editions#preview"

      get :delete, to: "editions#delete"

      # Workflow actions
      resources :workflow, only: %i[show update], controller: "editions/workflow", param: :step do
        collection do
          get :cancel, to: "editions/workflow#cancel"
        end
      end

      # record 2i Review outcomes
      get "review_outcomes/new", to: "editions/review_outcomes#new", as: :new_review_outcome
      post "review_outcomes", to: "editions/review_outcomes#create", as: :create_review_outcome
      get "review_outcomes/identify_performer", to: "editions/review_outcomes#identify_performer", as: :identify_performer_review_outcome
      put "review_outcomes", to: "editions/review_outcomes#update", as: :update_review_outcome

      # record fact check outcomes
      get "fact_check_outcomes/new", to: "editions/fact_check_outcomes#new", as: :new_fact_check_outcome
      post "fact_check_outcomes", to: "editions/fact_check_outcomes#create", as: :create_fact_check_outcome
      get "fact_check_outcomes/identify_performer", to: "editions/fact_check_outcomes#identify_performer", as: :identify_performer_fact_check_outcome
      put "fact_check_outcomes", to: "editions/fact_check_outcomes#update", as: :update_fact_check_outcome

      # State transitions
      resources :edition_status_transitions, only: [:create], controller: "editions/status_transitions"

      # Embedded object actions
      get "embedded-objects/(:object_type)/new", to: "editions/embedded_objects#new", as: :new_embedded_object
      post "embedded-objects", to: "editions/embedded_objects#new_embedded_objects_options_redirect", as: :new_embedded_objects_options_redirect
      post "embedded-objects/:object_type", to: "editions/embedded_objects#create", as: :create_embedded_object
      get "embedded-objects/:object_type/:object_title/edit", to: "editions/embedded_objects#edit", as: :edit_embedded_object
      put "embedded-objects/:object_type/:object_title", to: "editions/embedded_objects#update", as: :embedded_object

      # Reorder actions
      get :order, to: "editions/order#edit", as: :order_edit
      put :order, to: "editions/order#update", as: :order_update

      # Regenerate fact check preview link
      put :fact_check_preview_link, to: "editions/fact_check_preview_link#update", as: :update_fact_check_preview_link
    end
  end
end
