#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'blog.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT
	)'
	@db.execute 'CREATE TABLE IF NOT EXISTS Comments
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT,
		post_id integer
	)'
end

get '/' do
	@results = @db.execute 'select * from Posts order by id desc'
	erb :index		
end

get '/new' do
	erb :new
end

post '/new' do
  	content = params[:content]

  	if content.strip.empty?
  		@error = 'Type post text'
  		return erb :new
  	end

  	@db.execute 'insert into Posts (created_date,content) values (datetime(),?)',[content]

  	redirect to '/'

end

get '/post/:post_id' do

	# получаем переменную из url'a
	post_id = params[:post_id]

	results = @db.execute "select * from Posts where id = #{post_id}"

	@row = results[0]

	erb :details
end

post '/post/:post_id' do
	post_id = params[:post_id]
	comment = params[:comment]
	results = @db.execute "select * from Posts where id = #{post_id}"
	@row = results[0]
	if comment.strip.empty?
		@error = 'Type comment'
		return erb :details
	end
	erb "Comment added"
end

