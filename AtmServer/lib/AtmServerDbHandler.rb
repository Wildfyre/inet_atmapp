require 'sqlite3'
require 'colorize'
require_relative "atm_vars.rb"

class DatabaseHandler
    
    def initialize
        open_db
        reset_db
        fill_db
    end
    
    def open_db
        db_file = File.dirname(File.expand_path(__FILE__)) + '/../atm_server_database.db'
        @db = SQLite3::Database.open db_file
        debug "Database created"
        @db.results_as_hash = true
    end
    
    def reset_db
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
    
    def close_db
        @db.close if @db
    end
    
    def verify_user_pin(id, pin)
        debug "Trying to process request for id: #{id} pin: #{pin}."
        user = @db.execute "SELECT * FROM Users WHERE Id=#{id}" #returns hash in array
        user = user[0] #Detangles the array
        debug "User found as #{user.inspect}"
        
        if user == nil
            return false 
        elsif (pin == user["Pin"])
            return true
        else
            return false
        end
    end
    
    def process_transaction(id, transaction_amount)
        debug "Trying to process request for id: #{id}, transaction change: #{transaction_amount}."
        user = @db.execute "SELECT * FROM Users WHERE Id=#{id}" #returns hash in array
        
        if user == nil
            debug "No user found: User is #{user}."
            return false 
        end
        
        user = user[0] #Detangles the array
        debug "User found as #{user.inspect}"
        
        current_balance = user["Balance"].to_i
        future_balance = current_balance + transaction_amount
        
        debug "Transaction understood as follows; Current balance: #{current_balance}, transaction change: #{transaction_amount}, Resulting balance: #{future_balance}"
        
        if future_balance < 0
            return false
        else 
            #Update balance
            debug "Setting balance to #{future_balance}"
            query = "UPDATE Users SET Balance=\"#{future_balance}\" WHERE Id=\"#{user["Id"]}\""
            @db.execute query
            return future_balance
            #return future balance
        end
        
    end
    
    def verify_transaction(id, input_ver_code)
        debug "Trying to process request for id: #{id}, verification code: #{input_ver_code}."
        user = @db.execute "SELECT * FROM Users WHERE Id=#{id}" #returns hash in array
        
        if user == nil
            debug "No user found: User is #{user}."
            return false 
        end
        
        user = user[0] #Detangles the array
        debug "User found as #{user.inspect}"
        
        db_ver_code = user["VerificationCodes"][0,2].to_i
        debug "Valid user verification code found as #{db_ver_code}"
        
        if input_ver_code == db_ver_code
            new_ver_codes = user["VerificationCodes"][3..-1]
            debug "Trying to set new verification codes string to #{new_ver_codes}. Object is a #{new_ver_codes.class.name}."
            query = "UPDATE Users SET VerificationCodes=\"#{new_ver_codes}\" WHERE Id=\"#{user["Id"]}\""
            debug "Updating db with query #{query}"
            @db.execute query
            debug "Done!"
            return true
        else
            return false
        end
    end
    
    def get_current_banner
        banner = @db.execute "SELECT BannerMessage, BannerVersion FROM Banner ORDER BY BannerVersion DESC LIMIT 1"
        banner = banner[0]
        debug "Banner fetched as #{banner}"
        return banner["BannerMessage"]
    end
    
    def check_banner_version(checksum)
        current_banner_checksum = get_current_banner.hash.to_s[0..4].to_i
        return checksum == current_banner_checksum
    end
    
    def put_db
        puts @db.execute "SELECT * FROM Banner"
        debug "Printed all banners from database"
        
        puts @db.execute "SELECT * FROM Users"
        debug "Printed all users from database"
    end
    
    def debug string
        puts "Server/Database: #{string}".light_yellow if $debug
    end
end