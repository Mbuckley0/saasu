module Saasu
  
  class Base
    
    ENDPOINT = "https://secure.saasu.com/webservices/rest/r1"
    
    def initialize(xml)

      node = xml

      klass = self.class.name.split("::")[1].downcase

      # [CHRISK] types derived from Entity have attributes, 
      # everything else does not
      if is_a? Saasu::Entity
        node.attributes.each do |attr|
          send("#{attr[1].name.underscore.sub(/#{klass}_/, "")}=", 
                            attr[1].text)

        end
      end

      if defined? root
        node = node.child
      end

      node.children.each do |child|
        method_name = child.name.underscore.sub(/#{klass}_/, "")
        if !child.text?
          # [CHRISK] further children found here signifies a sub 
          # type. Pass in xml which allows entity to create itself
          # Nokogiri is wierd, why is inner text counted as child? 

          if child.children.size == 1 && child.child.text?
            send("#{child.name.underscore.sub(/#{klass}_/, "")}=", child.children.first.text) unless child.children.first.nil?

            puts "#{child.name} setting "
          else
            puts "#{self.class.name} sending child data\n #{child.to_s}\n to #{method_name}"
            send("#{method_name}=", child)
          end
        else
          puts "should be setting #{child.content}"
        end
      end
    end
    
    class << self
      
      # @param [String] the API key
      #
      def api_key=(key)
        @@api_key = key
      end
      
      # Return the API key
      #
      def api_key
        @@api_key
      end
      
      # @param [Integer] the file_uid
      #
      def file_uid=(uid)
        @@file_uid = uid
      end
      
      # Returns the file_uid
      #
      def file_uid
        @@file_uid
      end
      
      # Returns all resources matching the supplied conditions
      # @param [Hash] conditions for the request
      #
      def all(options = {})
        response = get(options)
        xml      = Nokogiri::XML(response).css("#{defaults[:collection_name]}")
        
        collection = xml.inject([]) do |result, item|
          result << new(item)
          result
        end
        collection
      end
      
      # Finds a specific resource by its uid
      # @param [Integer] the uid
      #
      def find(uid)
        response = get({:uid => uid}, false)
        xml      = Nokogiri::XML(response).css("#{defaults[:resource_name]}")
        new(xml.first)
      end
      
      # Allows defaults for the object to be set.
      # Generally the class name will be suitable and options will not need to be provided
      # @param [Hash] options to override the default settings
      #
      def defaults(options = nil)
        @defaults ||= default_options
        if options
          @defaults = default_options.merge!(options)
        else
          @defaults
        end
      end
       
      protected
        
        # Default options for the class
        #
        def default_options
          options                   = {}
          options[:query_options]   ||= {}
          options[:resource_name]   = name.split("::").last.downcase
          options[:collection_name] = name.split("::").last.downcase + "ListItem"
          options
        end
       
        def root(name)
          @root = name
        end

        def attributes(attributes = {})
          attributes.each do |k,v|
            define_accessor(k.underscore, v)
          end
        end

        # Defines the fields for a resource and any transformations
        # @param [Hash] key/value pair of field name and object type
        #
        def elements(elements = {})
          elements.each do |k,v|
            define_accessor(k.underscore, v)
          end
        end

        def define_accessor(field, type)
          m = field.sub(/^#{defaults[:resource_name]}_/, "")
          case type
          when :string 
            class_eval <<-END
              def #{m}=(v)
                @#{m} = v
              end
            END
          when :decimal
            class_eval <<-END
              def #{m}=(v)
                @#{m} = v.to_f
              end
            END
          when :date
            class_eval <<-END
              def #{m}=(v)
                @#{m} = Date.parse(v)
              end
            END
          when :integer
            class_eval <<-END
              def #{m}=(v)
                @#{m} = v.to_i
              end
            END
          when :boolean
            class_eval <<-END
              def #{m}=(v)
                @#{m} = (v.match(/true/i) ? true : false)
              end
            END
          when :array
            class_eval <<-END
              def #{m}=(v)
                @#{m} = v.children.to_a().map {|node| 
                  puts "node \#{node.node_name()} data \#{node.to_s()}"
                  Saasu.const_get(node.node_name()).new(node)
                }
              end
            END
          else
            class_eval <<-END
              def #{m}=(v)
                @#{m} = Saasu.const_get(:#{type}).new(v)
              end
            END
          end
         
          # creates read accessor
          class_eval <<-END
            def #{m}
              @#{m}
            end
          END
        end
        
        # Makes the request to saasu
        # @param [Hash] options for the request
        # @param [Boolean] toggles searching between collection and a singular resource
        #
        def get(options = {}, all = true)
          uri              = URI.parse(request_path(options, all))
          http             = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl     = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          response         = http.request(Net::HTTP::Get.new(uri.request_uri))
          (options[:format] && options[:format] == "pdf") ? response.body : response.body
        end
        
        def query_string(options = {})
          options = defaults[:query_options].merge(options)
          options = { :wsaccesskey => api_key, :fileuid => file_uid }.merge(options)
          options.map { |k,v| "#{k.to_s.gsub(/_/, "")}=#{v}"}.join("&")
        end
        
        def request_path(options = {}, all = true)
          path = (all == true ? defaults[:collection_name].sub(/Item/, "") : defaults[:resource_name])
          ENDPOINT + "/#{path}?#{query_string(options)}"
        end
      
    end
    
  end

end
