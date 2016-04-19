require 'yaml'
require_relative "atm_vars.rb"


class LanguageHandler
    def initialize(start_language=:English)
        scan_langs
        @active_language = @languages[start_language]
    end
    
    def scan_langs
        lang_file = File.dirname(File.expand_path(__FILE__)) + '/../langs.yml'
        @languages = YAML::load_file lang_file
        #@languages = YAML::load_file "langs.yml"
    end
    
    def get_str string_name_symbol
        return @active_language[string_name_symbol]
    end
    
    def set_lang symbol
        @active_language = @languages[symbol]
    end
    
    def debugpr(str)
        puts "Client/LangHandler: #{str}".light_blue
    end
end