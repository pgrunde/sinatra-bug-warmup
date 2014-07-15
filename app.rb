require "sinatra"
require "gschool_database_connection"
require "rack-flash"

class App < Sinatra::Base
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @database_connection = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
  end

  get "/" do
    erb :home
  end

  get "/register" do
    erb :register
  end

  post "/registrations" do
    if params[:name_is_hunter] == 0
      hunter_confirm = true
    else
      hunter_confirm = false
    end
    insert_sql = <<-SQL
      INSERT INTO users (username, email, password, name_is_hunter)
      VALUES ('#{params[:username]}', '#{params[:email]}', '#{params[:password]}', '#{hunter_confirm}')
    SQL

    begin
      @database_connection.sql(insert_sql)
      flash[:notice] = "Thanks for signing up"
    rescue
      flash[:notice] = "Username / Password / email combo invalid or already taken."
    end
    redirect "/"
  end

end