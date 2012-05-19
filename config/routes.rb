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
  end
end