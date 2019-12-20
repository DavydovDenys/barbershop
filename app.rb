require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def is_barber_exists? db, name
	db.execute('select * from Barbers where Barber=?', [name]).length > 0
end

def seed_db db, barbers

	barbers.each do |barber|
		if !is_barber_exists? db, barber
			db.execute 'insert into Barbers (Barber) values (?)', [barber]
		end 
	end

end

def get_db
	db = SQLite3::Database.new 'barbershop.db'
	db.results_as_hash = true
	return db
end

before do
	db = get_db
	@barbers = db.execute 'select * from Barbers'
end

configure do
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS
		"Users"
		(
			"Id" INTEGER PRIMARY KEY AUTOINCREMENT,
			"Username" TEXT,
			"Phone" TEXT,
			"DateStamp" TEXT,
			"Barber" TEXT,
			"Color" TEXT
		)'

	db.execute 'CREATE TABLE IF NOT EXISTS
		"Barbers"
		(
			"id" INTEGER PRIMARY KEY AUTOINCREMENT,
			"Barber" TEXT
		)'

	seed_db db, ['Jessie Pinkman', 'Walter White', 'Gus Fring', 'Mike Ehrmantraut']
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb '<h2>Мы лучшие</h2>'
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

	# хеш
	hh = { 	:name => 'Введите имя',
			:phone => 'Введите телефон',
			:datetime => 'Введите дату и время' }

	@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

	if @error != ''
		return erb :signin
	end

	db = get_db
	db.execute 'insert into
		Users
		(
			Name,
			Phone,
			DateStamp,
			Barber,
			Color
		)
		values (?, ?, ?, ?, ?)', [@name, @phone, @datetime, @barber, @color]

	erb "<h2>Спасибо, вы записались!</h2>"

end

get '/showusers' do
	db = get_db

	@results = db.execute 'select * from Users order by id desc'

	erb :showusers
end
