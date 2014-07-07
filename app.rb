require "sinatra"
require "./lib/database"
require "./lib/contact_database"
require "./lib/user_database"

class ContactsApp < Sinatra::Base
  enable :sessions

  def initialize
    super
    @contact_database = ContactDatabase.new
    @user_database = UserDatabase.new

    jeff = @user_database.insert(username: "Jeff", password: "jeff123")
    hunter = @user_database.insert(username: "Hunter", password: "puglyfe")

    @contact_database.insert(:name => "Spencer", :email => "spen@example.com", user_id: jeff[:id])
    @contact_database.insert(:name => "Jeff D.", :email => "jd@example.com", user_id: jeff[:id])
    @contact_database.insert(:name => "Mike", :email => "mike@example.com", user_id: jeff[:id])
    @contact_database.insert(:name => "Kirsten", :email => "kirsten@example.com", user_id: hunter[:id])
  end

  get "/" do
    if current_user
      erb :signed_in, locals: {username: current_user[:username]}
    else
      erb :signed_out
    end
  end

  get "/login/new" do
    erb :"login/new"
  end

  private

  def find_user(params)
    @user_database.all.select { |user|
      user[:username] == params[:username] && user[:password] == params[:password]
    }.first
  end

  def current_user
    if session[:user_id]
      @user_database.find(session[:user_id])
    end
  end
end

