require 'sinatra'
require 'sequel'
require 'sinatra/reloader'
require 'haml'

set :haml, :escape_html => true

set :session_secret, '453270c52057ed8b064a63b7f2f3e37c4846ce0d24307323551f672a8f7ec943f774533c7560cc9c1966f2b0075a5bddb00a75ee2f95dc2b42a26d4a3874bdd544a5fb1001624a6c18eaac64c0a08515c006f56a9e71e883549b58c706755ae505c40e6dedd785a1d6a5dced412fe59d47dd32cfa11e07e9fb45160964595b11'
enable :sessions
use Rack::Protection::AuthenticityToken

before do
  session[:csrf] = SecureRandom.hex(64) unless session.has_key?(:csrf)
end

Sequel::Model.plugin(:schema)
DB = Sequel.connect("sqlite://tweets.db")

class Tweets < Sequel::Model
  set_schema do
    primary_key :id
    string :entry
  end
end
Tweets.create_table unless Tweets.table_exists?

get '/new' do
  @title = '新規'
  haml :new
end

post '/create' do
  Tweets.create({
    :entry => request[:entry],
  })
  redirect "/"
end

get '/' do
  @title = '表示'
  @tweets = Tweets.all
  haml :index
end

get '/:tweet_id/edit' do
  @title = '編集'
  @tweet = Tweets[params[:tweet_id]]
  haml :edit
end

put '/:tweet_id/update' do
  Tweets[params[:tweet_id]].update({
    :entry => params[:entry]
  })
  redirect '/'
end

delete '/:tweet_id/delete' do
  Tweets[params[:tweet_id]].delete
  redirect '/'
end