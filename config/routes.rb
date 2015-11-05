Rails.application.routes.draw do
  root to: 'site#index'

  resources :donors do
    member do
      put 'cancel'
      put 'uncancel'
    end
    collection do
      get 'exists'
      put 'verify'
      get 'thanks'
      get 'fetch_state_by_zip'
      get 'map'
    end
  end
  resources :gifts, param: :guid, only: [:update, :new, :create] do
    member do
      get 'convert'
    end
    collection do
      get 'exists'
      get 'thanks'
    end
  end

  resources :nonprofits do
    get 'autotweet', on: :member
    get 'upcoming_report', on: :collection
  end

  resources :subscribers, param: :guid do
    member do
      get 'unsubscribe',                action: 'unsubscribe',  as: 'unsubscribe'
      put 'unsubscribe'
      put 'resubscribe'
      get 'donations',                  action: 'donations'
      get 'add_favorite/:nonprofit_id', to: redirect('/subscribers/%{guid}/favorites/%{nonprofit_id}/add')
      get 'email_login/:auth_token',    action: 'email_login',  as: 'email_login'
      get 'logout',                     action: 'logout'
    end
    collection do
      get 'thanks'
    end

    resources :favorites,     controller: 'subscriber/favorites',
                              as: :favorites,
                              only: [:index, :destroy, :create] do

      get 'add',          action: :create, as: :add, on: :member
    end
  end

  resources :newsletters do
    get :preview, on: :collection
  end
  devise_for :users, :skip => [:registrations]
  devise_scope :user do
    get "login"      => "devise/sessions#new"
    get 'users/edit' => 'devise/registrations#edit',   as: 'edit_user_registration'
    put 'users'      => 'devise/registrations#update', as: 'user_registration'
  end
  resources :users

  get  'about',            to: 'site#about'
  get  'calendar',         to: 'site#calendar'
  get  'faq',              to: 'site#faq'
  get  'subscribe',        to: 'subscribers#new',    as: :subscribe
  get  'donate',           to: 'donors#new',         as: :donate
  post 'donate',           to: 'donors#create'
  get  'gift',             to: 'gifts#new',          as: :gift_page
  post 'gift',             to: 'gifts#create'
  get  'legal',            to: 'site#legal'
  get  'contact',          to: 'site#contact'
  post 'send_feedback',    to: 'site#send_feedback'
  get  'wall_calendar',    to: 'site#wall_calendar'
  get  'autotweet',        to: 'site#autotweet'
  # Share to app (or) mobile browser javascript
  get 'share',             to: 'site#share',         as: :share

  # Admin
  get '/admin/mailers'         => "admin/mailers#index"
  get '/admin/mailers/*path'   => "admin/mailers#preview"
  namespace :admin do
    get 'delayed_jobs', to: 'base#delayed_jobs'

    resources :nonprofits do
      collection do
        get :lookup_ein
      end
    end
    resources :donors, except: [:new, :create]
    resources :donations
    resources :subscribers do
      member do
        put :resend_newsletter
      end
    end
    resources :stats
    resources :payouts, only: [:index, :create]
    resources :newsletters do
      member do
        get :preview
        post :send_preview
        get :donor_generated
        get :subscriber_generated
      end
    end
  end
end
