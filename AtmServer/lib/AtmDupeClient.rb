require 'colorize'
require_relative "AtmServer.rb"
require_relative "atm_vars.rb"

class AtmDupeClient
    
    # must me called with [port, ip, <whaterver>]
    def initialize(*args)
        @socket = TCPSocket.open(args[1], args[0])
    end
    
    def test_debug_request
        debug_print "Testing 'DBG' (Debug) requests.\n"
        debug_print "Expeted response: Time object."
        send_test_request ['DBG']
    end
    
    def test_login_request
        debug_print "Testing 'LOG' (Login) requests.\n"
        debug_print "Sending valid user with valid pin."
        debug_print "Expected resonse: SCS."
        send_test_request ['LOG', '123456', '1234']
        debug_print "Sending valid user with invalid pin."
        debug_print "Expected response: FLD."
        send_test_request ['LOG', '123456', 'FISH']
        debug_print "Sending invalid user."
        debug_print "Expected response: FLD."
        send_test_request ['LOG', '654321', '1234']
    end
    
    def test_transaction_request
        debug_print "Testing 'TRA' (Transaction) requests.\n"
        
        debug_print "Sending valid deposit 10000+5000."
        debug_print "Expected response: 15000."
        send_test_request ['TRA', '5000']
        
        debug_print "Sending valid deposit 15000-10000"
        debug_print "Expected response: 5000."
        send_test_request ['TRA', '-10000']
        
        debug_print "Sending valid balance check"
        debug_print "Expected response: 5000."
        send_test_request ['TRA', '0']
        
        debug_print "Sending invalid withdrawal 5000-10000"
        debug_print "Expected response: FLD."
        send_test_request ['TRA', '-10000']
        
        debug_print "Expected response: Placeholder sting."
        debug_print "Expected response: 5000."
        send_test_request ['TRA', '0']
    end
    
    def test_verification_request
        debug_print "Testing 'VER' (Verification) request.\n"
        debug_print "Expected response: SCS."
        send_test_request ['VER', '01']
        debug_print "Expected response: FLD."
        send_test_request ['VER', '10']
    end
    
    def test_banner_request
        debug_print "Testing 'BAN' (Banner) requests.\n"
        debug_print "Sending up-to-date banner hash"
        test_banner_hash = "Ask your banker about our great prices on houses in Florida!".hash.to_s[0..4]
        debug_print "Expected response: SCS"
        send_test_request ['BAN', test_banner_hash]
        
        debug_print "Sending out-of-date banner hash"
        test_banner_hash = "Ask your banker about our terrible prices on houses in Milan!".hash.to_s[0..4]
        debug_print "Expected response: Current banner message"
        send_test_request ['BAN', test_banner_hash]
    end
    
    def test_exit_request
        debug_print "Testing 'EXT' (Exit) request.\n"
        debug_print "Expected response: SCS."
        send_test_request ['EXT']
    end
    
    def shutdown
        debug_print "Shutdown command given. Shutting down."
        @socket.close
    end
    
    def debug_print str
        puts "Client: #{str}".light_cyan if $debug
    end
    
    def send_test_request request
        debug_print "Sending request #{request.inspect}"
        @socket.puts request
        debug_print "Recieved answer: #{@socket.gets}"
    end
end

# Call this with "ruby xxx/AtmDupeClient.rb $PORT $IP"
if __FILE__ == $0
    
    # Setup
    server = AtmServer.new *ARGV
    server.start
    client = AtmDupeClient.new *ARGV
    
    # Stuff to be tested
    puts "" # Just print a blank line for output niceness.
    client.test_debug_request
    client.test_login_request
    client.test_transaction_request
    client.test_verification_request
    client.test_banner_request
    client.test_exit_request
    
    # Teardown
    client.shutdown
    server.shutdown
    
end