require 'sqlite3'
require 'colorize'
require_relative "atm_vars.rb"

class DatabaseTester
    
    def initialize
    end
    
    def open_db
        @db = SQLite3::Database.open "test.db"
        debug "Database created"
        @db.results_as_hash = true
        
    end
    
    def reset_database
        @db.execute "DROP TABLE IF EXISTS Users"
        @db.execute "DROP TABLE IF EXISTS Banner"
    end
    
    def fill_db
        @db.execute "CREATE TABLE Banner(BannerVersion INTEGER PRIMARY KEY, BannerMessage TEXT)"
        debug "Banner table added to database"
        
        @db.execute "INSERT INTO Banner VALUES(1, 'Test banner, please ignore.')"
        @db.execute "INSERT INTO Banner VALUES(2, 'Ask your banker about our great prices on houses in Florida!')"
        
        @db.execute "CREATE TABLE Users(Id INTEGER PRIMARY KEY, Pin INT, Balance INT, VerificationCodes TEXT)"
        debug "Users table added to database"
        
        @db.execute "INSERT INTO Users VALUES(123456, 1234, 10000, '01x03x05x07x09x11x13x15x17x19x21x23x25')"
        @db.execute "INSERT INTO Users VALUES(234567, 1234, 10000, '01x03x05x07x09x11x13x15x17x19x21x23x25')"
        @db.execute "INSERT INTO Users VALUES(345678, 1234, 10000, '01x03x05x07x09x11x13x15x17x19x21x23x25')"
        @db.execute "INSERT INTO Users VALUES(456789, 1234, 10000, '01x03x05x07x09x11x13x15x17x19x21x23x25')"
        debug "Added test users to database"
    end
    
    def put_db
        puts @db.execute "SELECT * FROM Banner"
        debug "Printed all banners from database"
        
        puts @db.execute "SELECT * FROM Users"
        debug "Printed all users from database"
    end
    
    def test_get_user
        puts @db.execute "SELECT * FROM Users WHERE Id=123456"
        debug "Tried to get a test user"
    end
    
    def test_get_banner
        puts @db.execute "SELECT BannerMessage, BannerVersion FROM Banner ORDER BY BannerVersion DESC LIMIT 1"
    end
    
    def close_db
        @db.close if @db
    end
    
    def debug string
        puts string.light_magenta if true
    end
    
end

if __FILE__ == $0
    puts "Test program compiling.".green
    SQLite3::Database.new( "test.db" )
    tester = DatabaseTester.new
    tester.open_db
    tester.reset_database
    tester.fill_db
    tester.put_db
    tester.test_get_user
    tester.test_get_banner
    tester.close_db
end