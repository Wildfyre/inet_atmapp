require "colorize"
require "rubygems"
require "highline/import"

require_relative "AtmDupeServerLink.rb"
require_relative "AtmClientLanguageHandler.rb"
require_relative "AtmServerLink.rb"
require_relative "atm_vars.rb"

# This is the client a simple socket-driven client/server
# program, developed for a assignment at KTH, Sweden.
# This is the client part, fashioned as an ATM.
#
# Written by Erlindst in 2013-2015.

class AtmClient
    
    # Constructor. Port and ip is wherethe client will try to connect.
    def initialize(port, ip)
        @banner = "This is a test banner and should never be visible. If you read this, please contact tech."
        @server_link = ServerLink.new port, ip
        @lang_handler = LanguageHandler.new
    end
    
    #Runs the user interface.
    def do_users_bidding
        say @lang_handler.get_str :terminal_greeting
        
        print_banner
        
        return unless login_user
        
        run_menu_loop
                
        say @lang_handler.get_str :terminal_farewell
    end
   
    #Prints the current banner from the bank to the user.
    def print_banner
        if @banner
            banner_hash = @banner.hash.to_s[0..4]
            banner_update = @server_link.update_banner_if_needed banner_hash
            @banner = banner_update unless banner_update == true
        else
            @banner = @server_link.get_banner
        end
        
        say @banner
    end
    
    #THe main interface loop method.
    def run_menu_loop
        loop do
            say("\nYour options are:")
            choose do |menu|
                menu.prompt = "> "
                menu.shell  = true
        
                menu.choice((@lang_handler.get_str :menu_choice_balance), (@lang_handler.get_str :menu_description_balance)) do |command, details|
                    process_balance
                end
                  
                menu.choice((@lang_handler.get_str :menu_choice_deposit),(@lang_handler.get_str :menu_description_deposit)) do |command, details|
                    process_deposit
                end
                
                menu.choice((@lang_handler.get_str :menu_choice_withdraw), (@lang_handler.get_str :menu_description_withdraw)) do |command, details|
                    return unless verify_withdrawal_by_code
                    process_withdraw
                end
                
                menu.choice((@lang_handler.get_str :menu_choice_language), (@lang_handler.get_str :menu_description_language)) do |command, details|
                    process_language_select
                end
                
                menu.hidden((@lang_handler.get_str :menu_choice_help), (@lang_handler.get_str :menu_description_help)) do
                    debugpr "Help-option selected."
                    say @lang_handler.get_str :help_message
                end
            
                menu.choice((@lang_handler.get_str :menu_choice_quit), (@lang_handler.get_str :menu_description_quit)) do
                    process_exit
                    exit
                end
            end
        end
    end
    
    #Asks the user to enter an verification code.
    def verify_withdrawal_by_code
            user_vc = ask((@lang_handler.get_str :verification_request), Integer) do |q| 
                q.in = 0..99
            end
            
            if @server_link.verify_user_transaction user_vc
                say @lang_handler.get_str :verification_success
                return true
            else
                say @lang_handler.get_str :verification_fail
                return false
            end
    end
    
    #Prints response from attempt to login user.
    def login_user
        successful_login = @server_link.login_user *request_user_information
        
        if successful_login
            say @lang_handler.get_str :login_success
            return true
        else
            process_exit
            say @lang_handler.get_str :login_fail
        end
    end
    
    #Takes user ID and pin for login.
    def request_user_information
        user_id = ask((@lang_handler.get_str :login_id_request), Integer) do |q| 
            q.in = 0..999999
        end
        
        user_pin = ask((@lang_handler.get_str :login_pin_request), Integer) do |q| 
            q.echo = false
            q.in = 0..9999
        end
        
        return user_id, user_pin
    end
    
    #Processes and responds to a balance request from the main user interface menu.
    def process_balance
        say "#{@lang_handler.get_str :balance_request}: #{@server_link.make_transaction 0}"
        return true
    end
    
    #Processes and responds to a withdrawal request from the main user interface menu.
    def process_withdraw
        amount = ask((@lang_handler.get_str :withdraw_request), Integer) do |q| 
            q.in = 0..10000
        end
        
        transaction_result = @server_link.make_transaction (amount * -1)
        
        if transaction_result
            say "#{@lang_handler.get_str :withdraw_success}: #{amount}"
            say "#{@lang_handler.get_str :withdraw_success_balance}: #{@server_link.make_transaction 0}"
        else
            say @lang_handler.get_str :withdraw_fail
            say "#{@lang_handler.get_str :withdraw_fail_balance}: #{@server_link.make_transaction 0}"
        end
        
        return true
    end
    
    #Processes and responds to a deposit request from the main user interface menu.
    def process_deposit
        amount = ask((@lang_handler.get_str :deposit_request), Integer) do |q| 
            q.in = 0..10000
        end
        
        
        transaction_result = @server_link.make_transaction amount
        say "#{@lang_handler.get_str :deposit_success} #{amount}!"
        say "#{@lang_handler.get_str :deposit_success_balance}: #{@server_link.make_transaction 0}"
        return true
    end
    
    #Processes and responds to a language select request from the main user interface menu.
    def process_language_select
        say @lang_handler.get_str :lang_menu_options
        choose do |menu|
          menu.prompt = @lang_handler.get_str :lang_request
        
          menu.choice :English do
              @lang_handler.set_lang :English
              say @lang_handler.get_str :lang_success
          end
        end
        
        return true
    end
    
    #Exits the user interface and client program.
    def process_exit
        @server_link.exit_server_connection
    end
    
    #Debug print method.
    def debugpr(str)
        puts "Client/Main: #{str}".blue
    end
    
end



if __FILE__ == $0
    say "Setting up program and creating client in local debug mode.".blue
    client = AtmClient.new
    client.do_users_bidding
end