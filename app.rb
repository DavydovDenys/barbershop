#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def is_barber_exists? db, barber_name
	db.execute('SELECT * FROM Barbers WHERE Barber=?', [barber_name]).length > 0
end

def seed_db db, barbers
	barbers.each do |barber|
		if !is_barber_exists? db, barber
			db.execute 'INSERT INTO Barbers (Barber) VALUES (?)', [barber]
		end
	end
end

def get_db
	db = SQLite3::Database.new('barbershop.db')
	db.results_as_hash = true
	return db
end

configure do
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS
		"Users"
		(
			"Id" INTEGER PRIMARY KEY AUTOINCREMENT,
			"Name" TEXT,
			"Phone" TEXT,
			"DateStamp" TEXT,
			"Barber" TEXT,
			"Color" TEXT
		)'
	db = get_db	
	db.execute 'CREATE TABLE IF NOT EXISTS
		"Barbers"
		(	
			"Id" INTEGER PRIMARY KEY AUTOINCREMENT,
			"Barber" TEXT
		)'
	seed_db db, ['Рон Алпен', 'Петер Луст', 'Джон Коннор', 'Том Рой']
	db.close
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
  erb "<h1>Мы лучшие!</h1>"
end

get '/signin' do
	erb :signin
end

post '/signin' do
	@name = params[:name]
	@phone = params[:phone]
	@datetime = params[:datetime]
	@barber = params[:barber]
	@color = params[:colorpicker]

	arr = [@name, @phone, @datetime, @barber, @color]

	arr.each do |item|
		if item == ''
			@error = 'Все поля должны быть заполнены!'
			return erb :signin
		end
	end
	db = get_db
	db.execute 'INSERT INTO "Users"
		(
			Name,
			Phone,
			DateStamp,
			Barber,
			Color
		)
		VALUES(?, ?, ?, ?, ?)', [@name, @phone, @datetime, @barber, @color]
	db.close

	db = get_db
	db.execute 'INSERT INTO "Barbers"
		(
			Barber
		)
		VALUES(?)', [@barber]
	db.close

	erb '<h2>Спасибо! Вы записаны!</h2>'


end