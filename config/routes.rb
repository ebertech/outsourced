Outsourced::Engine.routes.draw do
  namespace :v1 do
    resources :jobs, :controller => "outsourced/jobs" do
      collection do
        put :next
      end
      member do
        get :attachment
      end
    end

    resource :oauth do

      match '/oauth/test_request', :to => 'oauth#test_request', :as => :test_request
      match '/oauth/token', :to => 'oauth#token', :as => :token
      match '/oauth/access_token', :to => 'oauth#access_token', :as => :access_token
      match '/oauth/request_token', :to => 'oauth#request_token', :as => :request_token
      match '/oauth/authorize', :to => 'oauth#authorize', :as => :authorize
      match '/oauth', :to => 'oauth#index', :as => :oauth
    end
  end
end