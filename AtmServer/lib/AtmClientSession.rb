require 'colorize'
require_relative "atm_vars.rb"

class ClientSession
    
    def initialize(database_link)
        @logged_in = false
        @client_id = false
        @db = database_link
    end
    
    def process_atm_request(io)
        request = get_input io
        debug_print "Starting to process request: #{request.inspect}"
        
        case request
        when 'LOG'
            id = get_input(io).to_i
            pin = get_input(io).to_i
            if @db.verify_user_pin(id, pin)
                @logged_in = true
                @client_id = id
                io.puts 'SCS'
            else
                io.puts 'FLD'
            end
            #io.puts "LOG placeholder - ID: #{id.inspect}, PIN: #{pin.inspect}"
        when 'TRA'
            transaction_amount = get_input(io).to_i
            result =  @db.process_transaction(@client_id, transaction_amount)
            if result == false
                io.puts 'FLD'
            else
                io.puts result
            end
            #io.puts "TRA placeholder - amount: #{transaction_amount.inspect}"
        when 'VER'
            verification_code = get_input(io).to_i
            if !@logged_in
                io.puts 'FLD'
            elsif @db.verify_transaction(@client_id, verification_code)
                io.puts 'SCS'
            else
                io.puts 'FLD'
            end
            #io.puts "VER placeholder - verification code: #{verification_code.inspect}"
        when 'BAN'
            client_banner_hash = get_input(io).to_i
            if @db.check_banner_version(client_banner_hash)
                io.puts 'SCS'
            else
                io.puts @db.get_current_banner
            end
            #io.puts "BAN placeholder - CBH: #{client_banner_hash.inspect}"
        when 'EXT'
            io.puts "SCS"
            return false
        when 'DBG'
            io.puts Time.now.to_s
        else
            puts "Error! Bad request: #{request.inspect}".red
        end
        return true
    end
    
    def get_input(io)
        io.gets.strip.chomp
    end
    
    def debug_print str
        puts "Server/Session: #{str}".light_magenta if $debug
    end

end