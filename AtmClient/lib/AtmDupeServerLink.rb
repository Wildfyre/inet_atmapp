require "colorize"
require_relative "atm_vars.rb"

class DupeServerLink
    
    def initialize(port)
        @balance = 10000;
        @banner = "Ask your banker about or houses in Florida!"
    end
    
    def login_user(user_id, user_pin)
        return true
    end
    
    def verify_user_transaction(verification_code)
        return verification_code == 1
    end
    
    def make_transaction(transaction_amount)
        if (@balance + transaction_amount) < 0
            return false
        else
            @balance += transaction_amount
            return @balance
        end
    end
    
    def update_banner_if_needed hash
        unless hash == get_banner_hash
            return get_banner
        else
            return false
        end
    end
    
    def get_banner
        return @banner
    end
    
    def get_banner_hash
        @banner.hash.to_s[0..4]
    end
    
    def exit_server_connection
        return true
    end
    
    
    
end