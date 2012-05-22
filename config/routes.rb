Outsourced::Engine.routes.draw do
  namespace :v1 do
    resources :jobs, :controller => "outsourced/jobs" do
      collection do
        put :next
      end
    end
  end
end