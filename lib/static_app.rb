
class StaticApp < Sinatra::Base

  set :views, 'views'
  set :public_folder, 'public'

  get '/' do
    haml :index
  end

end
