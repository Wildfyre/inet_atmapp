#This is a script file to demo the Atm client/server pair. Made to work with C9.io.
# Call this with "ruby demo.rb $PORT $IP" if on c9 ide.

# Files and gems
require_relative "AtmServer/lib/AtmServer.rb"
require_relative "AtmClient/lib/AtmClient.rb"
require "colorize"

class Demonstrator
    
    def initialize(port, ip)
        @port, @ip = port, ip
        $debug = true           #Controls both Client and server debugging. Wordy, but extensively useful
    end
    
    def debugpr str
        puts "Demo: #{str}".green if $debug
    end
    
    def demonstrate(start_server, start_client)
        
        if start_server 
            server = AtmServer.new @port, @ip
            server.start
            debugpr "Server started: #{server.inspect}"
        end
        
        if start_client 
            client = AtmClient.new @port, @ip
            client.do_users_bidding
        end
        
        if start_server
            debugpr "Joining server command thread"
            server.audit
            server.join
            server.shutdown
        end
        
        debugpr "Everyhing shut down."
    end
end

if __FILE__ == $0
    port = ARGV[0]
    ip = ARGV[1]
    start_server = (ARGV[2] == "true")
    start_client = (ARGV[3] == "true")
    demo = Demonstrator.new port, ip
    demo.demonstrate start_server, start_client
end
