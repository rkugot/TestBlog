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
		username TEXT,
		created_date DATE,
		content TEXT
	)'
	@db.execute 'CREATE TABLE IF NOT EXISTS Comments
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT,
		post_id INTEGER
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
  	@content = params[:content]
  	@username = params[:username]

  	hh = {:content => 'Type post text',
  		  :username => 'Type your name'}
  	@error = hh.select{|key,value| params[key] == ''}.values.join(', ')

  	if @error != ''
  		return erb :new
  	end

  	@db.execute 'insert into Posts (username,created_date,content) values (?,datetime(),?)',[@username,@content]

  	redirect to '/'

end

get '/post/:post_id' do

	# получаем переменную из url'a
	post_id = params[:post_id]

	results = @db.execute "select * from Posts where id = ?",[post_id.to_i]

	@row = results[0]

	@comments = @db.execute "select * from Comments where post_id = ? order by id",[post_id.to_i]

	erb :details
end

post '/post/:post_id' do
	post_id = params[:post_id]
	comment = params[:comment]
	results = @db.execute "select * from Posts where id = ?",[post_id.to_i]
	@row = results[0]
	@comments = @db.execute "select * from Comments where post_id = ? order by id",[post_id.to_i]
	
	if comment.strip.empty?
		@error = 'Type comment'
		return erb :details
	end

	@db.execute 'insert into Comments (created_date,content,post_id) values (datetime(),?,?)',[comment,post_id.to_i]

	redirect to "post/#{post_id}"
end

