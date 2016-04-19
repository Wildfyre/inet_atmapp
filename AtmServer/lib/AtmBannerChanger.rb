require "colorize"
require "rubygems"
require "highline/import"
require "sqlite3"

class ServerAdminInterface
    
    def initialize
        open_database File.dirname(File.expand_path(__FILE__)) + '/../atm_server_database.db'
        @debug = $debug
    end
    
    def run_user_interface
        say "Welcome to the bank SAI (Server Administration Interface)."
        loop do
            say("\nYour options are:")
                choose do |menu|
                    menu.prompt = "> "
                    menu.shell  = true
            
                    menu.choice("See the current server banner.") do
                        display_banner
                    end
                    
                    menu.choice("Set a new banner.") do
                        new_banner = ask("Please enter a new banner.", String) do |q| 
                            q.limit = 80
                        end
                        
                        set_banner new_banner
                    end
                    
                    menu.choice("List all bank clients") do
                        list_clients
                    end
                
                    menu.choice("Exit program.") do
                        say "Exting SAI."
                        exit
                    end
                end
        end
    end
    
    def open_database(file)
        @db = SQLite3::Database.open file
        debugpr "Database opened."
        
        @db.results_as_hash = true
        
        if get_banner == false
            debugpr "Database could not be opened. Please investigate."
        end
    end
    
    def display_banner
        banner = get_banner
        say "Current banner is: \"#{banner["BannerMessage"]}\"."
    end
    
    def get_banner
        banner = @db.execute "SELECT BannerMessage, BannerVersion FROM Banner ORDER BY BannerVersion DESC LIMIT 1"
        banner = banner[0]
        debugpr "Banner fetched as #{banner}"
        return banner
    end
    
    def set_banner(new_banner)
        new_banner_version = get_banner["BannerVersion"] + 1
        update_command = "INSERT INTO Banner VALUES(#{new_banner_version}, '#{new_banner}')"
        debugpr "Sending update command: #{update_command}"
        @db.execute update_command
    end
    
    def get_clients
        command = "SELECT * FROM Users"
        debugpr "Sending db command: #{command}"
        return @db.execute command
    end
    
    def list_clients
        clients_hash = get_clients
        
        clients_hash.each_with_index do |client, index|
            say "Client #{index}: Id: #{client["Id"]}, Pin: #{client["Pin"]}, Balance: #{client["Balance"]}, Next VeriCode: #{client["VerificationCodes"][0..1]}"
        end
    end
    
    def debugpr(str)
        puts "ServerAdminInterface: #{str}".light_black if @debug
    end
end

if __FILE__ == $0
    $debug = false
    say "Starting Server Administration Interface.".light_black if $debug
    interface = ServerAdminInterface.new
    interface.run_user_interface
end