require_relative "atm_vars.rb"

class ServerLink
    
    def initialize(port, ip)
        @socket = TCPSocket.open ip, port
    end

    def login_user(user_id, user_pin)
        send_request ['LOG', user_id, user_pin]
        return get_response
    end
    
    def verify_user_transaction(verification_code)
        send_request ['VER', verification_code]
        return get_response
    end
    
    def make_transaction(transaction_amount)
        send_request ['TRA', transaction_amount]
        return get_response
    end
    
    def update_banner_if_needed hash
        send_request ['BAN', hash]
        return get_response
    end
    
    def exit_server_connection
        send_request ["EXT"]
        get_response
    end
    
    def send_request request
        debugpr "Sending request #{request.inspect}"
        @socket.puts request
    end
    
    def get_response
        response = @socket.gets.strip.chomp
        debugpr "Recieved answer: #{response}"
        return translate_response response
    end
    
    def translate_response(response)
        if response == nil
            debugpr_error "Response translated as NIL. Please investigate."
        elsif response == 'FLD'
            debugpr "Response translated as \'FLD\' and returned as false."
            return false
        elsif response == 'SCS'
            debugpr "Response translated as \'SCS\' and returned as true."
            return true
        else
            debugpr "Response not translated, returned as #{response.class.name}: #{response}."
            return response
        end
    end
    
    def debugpr(str)
        puts "Client/ServerLink: #{str}".light_blue if $debug
    end
    
    def debugpr_error(str)
        puts "Client/ServerLink: #{str}".upcase.red if $debug
    end
    
end