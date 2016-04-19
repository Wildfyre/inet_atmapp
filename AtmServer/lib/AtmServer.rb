require 'gserver'
require 'colorize'
require_relative "AtmServerDbHandler.rb"
require_relative "AtmClientSession.rb"
require_relative "atm_vars.rb"

class AtmServer < GServer
    
    def initialize(port=10001, *args)
        super(port, *args)
        @debug = $debug
        @db = DatabaseHandler.new
    end
    
    def serve(io)
        session = ClientSession.new @db
        loop do
            break unless session.process_atm_request(io)
            debug_print "Request processing finished. Moving to read next request."
        end
        debug_print "Client session closed, awaiting incoming connections."
    end
    
    def get_input(io)
        io.gets.strip.chomp
    end
    
    def debug_print str
        puts "Server/Main: #{str}".magenta if $debug
    end
    
    def shutdown
        debug_print "Shutdown command given. Shutting down."
        super
    end
    
end

if __FILE__ == $0
    server = AtmServer.new *ARGV
    puts "created server".yellow
    server.start
    puts "started server".yellow
    server.shutdown
    puts "shuts down server".yellow
end