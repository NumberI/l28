#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new "Lepro.db"
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'CREATE  TABLE IF NOT EXISTS "Posts" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "created_date" DATETIME, "content" TEXT, author text)'
	@db.execute 'CREATE  TABLE IF NOT EXISTS Comments ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "created_date" DATETIME, "content" TEXT, post_id integer, author text)'
end

get '/' do
	@results = @db.execute "SELECT * FROM Posts order by id desc"
	erb :index
end
get '/new' do
	erb :new		
end
post '/new' do
	content = params[:text]
	author = params[:author]
	if content.length <= 0 || author.length <=0
		@error = "Введите текст"
		return erb :new
	end
	@db.execute "INSERT INTO Posts ( created_date , content, author ) VALUES ( datetime(), ?, ?)", [content, author]
	redirect to "/"
end

get "/details/:post_id" do
	post_id = params[:post_id]
	results = @db.execute "SELECT * FROM Posts where id = ?",[post_id]
	@row = results[0]
	@comments = @db.execute "SELECT * FROM Comments where post_id = ? order by id", [post_id]
	erb :details
end

get "/people/:author" do
	author = params[:author]
	@posts = @db.execute "SELECT * FROM Posts where author = ?",[author]
	
	@coms = @db.execute "SELECT * FROM Comments where author = ? order by id", [author]
	erb :people
end

post "/details/:post_id" do
	post_id = params[:post_id]
	content = params[:text]
	author = params[:author]
	if content.length <= 0 || author.length <=0 
		@error = "Введите текст"
		redirect to ("/details/" + post_id)
	end
	@db.execute "INSERT INTO Comments ( created_date , content, post_id, author ) VALUES ( datetime(), ?, ?, ?)", [content, post_id, author]
	#results = @db.execute "SELECT * FROM Posts where id = ?",[post_id]
	#@row = results[0]
	#erb "#{content} for post #{post_id}"
	redirect to ("/details/" + post_id)
end