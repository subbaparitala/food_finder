require 'restaurant'
require 'support/string_extend'

class Guide
    class Config
        @@actions = ['list', 'find','add','quit']
        def self.actions; @@actions; end
    end
    
    def initialize(path=nil)
        Restaurant.filepath = path
        if Restaurant.file_usable?
            puts "File Found"
        elsif Restaurant.create_file
            puts "creating a file"
        else
            puts "Exiting\n\n"
            exit!
        end
    end
    
    def launch!
        introduction
        result = nil
        until result == :quit  
            action, args = get_action
            result = do_action(action, args)
            
        end   
        conculsion
    end

    def get_action
        action = nil
        until Guide::Config.actions.include?(action)
            puts "Actions: " + Guide::Config.actions.join(", ") if action 

            print "> "
            user_response = gets.chomp
            args = user_response.downcase.strip.split(' ')
            action = args.shift
        end
        return action, args

    end

    def do_action(action, args=[])
        case action
        when 'list'
            list(args)
        when 'add'
            add
        when 'find'
            keyword = args.shift
            find(keyword)
        when 'quit'
            return :quit
        else 
            puts "I dont understand what your command"
        end
    end

    def add

        output_action_header("Adding a Restaurant")
        
        restaurant = Restaurant.build_using_questions

        

        if restaurant.save
            puts "Resturanta Added"
        else
            puts "Save error "
        end
    end
    def list(args=[])

        sort_order = args.shift
        sort_order = args.shift if args.shift == 'by'
        sort_order = "name" unless ['name', 'cusine', 'price'].include?(sort_order)
        output_action_header("Listing Restaurants")

        restaurants = Restaurant.saved_restaurants
        restaurants.sort! do |r1, r2|
            case sort_order
            when 'name'
                r1.name.downcase <=> r2.name.downcase
            when 'cusine'
                r1.cusine.downcase <=> r2.cusine.downcase
            when 'price'
                r1.price.to_i <=> r2.price.to_i
            end
        end
        output_restaurant_table(restaurants)
        puts "Sort using: 'list cusine' or 'list by cusine'\n\n"
    end
    def output_action_header(text)
        puts "\n#{text.upcase.center(60)}\n\n"
    end
    def output_restaurant_table(restaurants=[])
        print " " + "Name".ljust(30)
        print " " + "Cusine".ljust(20)
        print " " + "Price".rjust(6) + "\n"
        puts "-" * 60
        restaurants.each do |rest|
            line = " " <<rest.name.titleize.ljust(30)
            line << " " + rest.cusine.titleize.ljust(20)
            line << " " + rest.formatted_price.titleize.rjust(6)
            puts line
        end
        puts "No listing found" if restaurants.empty?
        puts "-" * 60
    end

    def introduction
        puts "\n\n<<< Welcome to the Resturant Food Finder>>>\n\n"
        puts "\n\nThis is an interactive guide to help you to find food\n\n"
        end
    
    def conculsion
        puts "Have a good food bye and Bon Apetite"
    end

    def find(keyword="")
        output_action_header("Finding a Restaurant")

        if keyword
            restaurants = Restaurant.saved_restaurants
            found = restaurants.select do |rest|
                rest.name.downcase.include?(keyword.downcase) ||
                rest.cusine.downcase.include?(keyword.downcase) ||
                rest.price.to_i <= keyword.to_i
            end
            output_restaurant_table(found)
        else
            puts "Find using a key value "
            puts "Example: Andhara: \n\n"
        end
    end




end

