module Saasu

  class ::Date
    def to_saasu_iso8601()
      strftime("%FT%R")
    end
    def to_saasu()
      strftime("%F")
    end
  end

  class Base
    
    ENDPOINT = "https://secure.saasu.com/webservices/rest/r1"

    STANDARD_TYPES = [
      :string,
      :decimal,
      :date,
      :integer,
      :boolean,
      :array
    ]

    attr_accessor :errors

    def initialize(xml = nil)
      unless xml.eql? nil
        construct_from_xml(xml)
      end
    end

    def construct_from_xml(xml)

      if xml.is_a? Nokogiri::XML::Document
        node = xml.root
      else
        node = xml
      end

      if respond_to? :has_attributes?
        node.attributes.each do |attr|
          send("#{attr[1].name.underscore}=", attr[1].text)
        end
      end

      unless node.children.size == 0
        node.children.each do |child|
          if !child.text?
            if child.children.size == 1 && child.child.text?
              send("#{child.name.underscore}=", child.child.text) unless child.child.nil?
            else
              send("#{child.name.underscore}=", child) unless child.child.nil?
            end
          else
            puts "unexpected text node #{child.name} with content #{child.content}!"
          end
        end
      end
    end

    def to_xml()
      doc = Nokogiri::XML::Document.new()

      if defined? @@root
        root_xml = wrap_xml(@@root.camelize(:lower))
      else
        root_xml = wrap_xml(self.class.name.split("::")[1].camelize(:lower))
      end

      node = doc.add_child( root_xml )
 
      attributes = {}

      if is_a? Entity 
        attributes = Entity.class_attributes
      elsif is_a? InsertResult
        attributes = InsertResult.class_attributes
      elsif is_a? UpdateResult
        attributes = UpdateResult.class_attributes
      elsif is_a? DeleteResult
        attributes = DeleteResult.class_attributes
      end

      unless self.class.class_attributes.nil?
        attributes = attributes.merge(self.class.class_attributes)
      end

      attributes.each do |k, v| 
        node["#{k}"] = send(k.underscore).to_s
      end

      elements = {}

      if is_a? Transaction
        elements = Transaction.class_elements
      end

      unless self.class.class_elements.nil?
        elements = elements.merge(self.class.class_elements)
      end

      unless elements.nil? || elements.empty?
        elements.each do |k, v|
          if v.eql? :array
            ap = node.add_child(wrap_xml(k.camelize(:lower)))
            if ap.is_a? Nokogiri::XML::NodeSet
              ap = ap.first()
            end
            array = send(k.underscore)
            unless array.nil? || array.empty?
              array.each() do |e|
                ap.add_child( e.to_xml.root )
              end
            end
          elsif STANDARD_TYPES.include?(v)
            node.add_child(wrap_xml(k.camelize(:lower), send(k.underscore)))
          else
            o = send(k.underscore)
            unless o.nil?
              node.add_child(o.to_xml().root)
            else
              node.add_child(wrap_xml(k.camelize(:lower)))
            end
          end
        end
      end

      doc
    end

    def wrap_xml(node_name, node_inner_data = nil) 
      if node_inner_data.nil? 
        "<#{node_name}></#{node_name}>"
      else
        if (node_inner_data.is_a? Date) || (node_inner_data.is_a? DateTime)
          "<#{node_name}>#{node_inner_data.to_saasu}</#{node_name}>"
        else
          "<#{node_name}>#{node_inner_data}</#{node_name}>"
        end
      end 
    end
   
    class << self
   
      attr_accessor :class_root
      attr_accessor :class_attributes
      attr_accessor :class_elements

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
        xml      = Nokogiri::XML(response)

        klass_list_item = "#{klass_name}ListItem"

        xsl = 
          "<xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">
            <xsl:template match=\"*\">
              <xsl:copy>
                <xsl:copy-of select=\"@*\" />
                <xsl:apply-templates />
              </xsl:copy>
            </xsl:template>
            <xsl:template match=\"text()\">
              <xsl:value-of select=\"normalize-space(.)\"/>
            </xsl:template>
            <xsl:template match=\"/#{klass_name}ListResponse\">
                <xsl:copy>
                <xsl:copy-of select=\"@*\" />
                <xsl:apply-templates />
                </xsl:copy>
            </xsl:template>
            <xsl:template match=\"#{klass_name}List\">
                <xsl:copy>
                <xsl:copy-of select=\"@*\" />
                <xsl:apply-templates />
                </xsl:copy>
            </xsl:template>
            <xsl:template match=\"#{klass_list_item}\">
                <!-- <#{klass_name.camelize(:lower)}> -->
                <xsl:copy>
                <xsl:copy-of select=\"@*\" />
                <xsl:apply-templates />
                </xsl:copy>
                <!-- </#{klass_name.camelize(:lower)}> -->
            </xsl:template>
            <xsl:template match=\"#{klass_name}Uid\">
              <uid><xsl:value-of select=\".\" /></uid>
            </xsl:template>
          </xsl:stylesheet>"

        xslt = Nokogiri::XSLT.parse(xsl)
        xml = xslt.transform(xml)

        #print "#{xml.to_s()}\n"

        #File.open("#{klass_list_item}.xml".underscore, 'w') { |f| f.write(xml.to_s()) }

        nodes = xml.css(klass_list_item)

        collection = nodes.inject([]) do |result, item|
          klass = Saasu.const_get(klass_list_item.camelize(:upper).to_sym)
          result << klass.new(item)
          result
        end
        collection
      end
      
      # Finds a specific resource by its uid
      # @param [Integer] the uid
      #
      def find(uid)
        response = get({:uid => uid}, false)
        xml = Nokogiri::XML(response)

        xsl =
        "<xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">
            <xsl:template match=\"/#{klass_name}Response\">
                <xsl:apply-templates />
            </xsl:template>
            <xsl:template match=\"text()\">
              <xsl:value-of select=\"normalize-space(.)\"/>
            </xsl:template>
            <xsl:template match=\"*\">
              <xsl:copy>
                <xsl:copy-of select=\"@*\" />
                <xsl:apply-templates />
              </xsl:copy>
            </xsl:template>
         </xsl:stylesheet>"


        #print "#{xml.to_s}\n" 

        xslt = Nokogiri::XSLT.parse(xsl)
        xml = xslt.transform(xml)

        new(xml.root)
      end

      def insert(entity)
        post({ :entity => entity, :task => :insert })
      end

      def update(entity)
        post({ :entity => entity, :task => :update })
      end

      def delete(uid)
        _delete(uid)
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
          @class_root = name
        end

        def attributes(attributes = {})
          attributes.each do |k,v|
            define_accessor(k.underscore, v)
          end
          class_eval <<-END
            def has_attributes?
              true
            end
          END
          @class_attributes = attributes
        end

        # Defines the fields for a resource and any transformations
        # @param [Hash] key/value pair of field name and object type
        #
        def elements(elements = {})
          elements.each do |k,v|
            define_accessor(k.underscore, v)
          end
          @class_elements = elements
        end

        def define_accessor(element, type)
          m = element
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
                unless v.nil?
                  if v.is_a? String
                    unless v.empty?
                      @#{m} = Date.parse(v)
                    end
                  elsif v.is_a? Date
                    @#{m} = v 
                  else
                    raise TypeError, 'Expecting Date or String'
                  end
                end
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
                if (v.is_a? TrueClass) || (v.is_a? FalseClass)
                  @#{m} = v;
                elsif v.is_a? String
                  @#{m} = (v.match(/true/i) ? true : false)
                else
                  raise TypeError, 'Expecting true/false or string'
                end
              end
            END
          when :array
            class_eval <<-END
              def #{m}=(v)
                if v.is_a? Nokogiri::XML::Node
                  @#{m} = v.children.to_a().map {|node| 
                    Saasu.const_get(node.node_name().camelize).new(node)
                  }
                elsif v.is_a? Array 
                  @#{m} = v
                else
                  raise TypeError, 'Expecting an Array or XML Node'
                end
              end
            END
          else
            class_eval <<-END
              def #{m}=(v)
                if v.is_a? Base
                  @#{m} = v
                else 
                  @#{m} = Saasu.const_get(:#{type}).new(v)
                end
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

          #puts "Request URL (GET) is #{uri.request_uri}" 

          response = http.request(Net::HTTP::Get.new(uri.request_uri))
          response.body
        end

        def post(options)
          uri = URI.parse(task_path())
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true;
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE

          #puts "Request URL (POST) is #{uri.request_uri}"

          post = Net::HTTP::Post.new(uri.request_uri)

          doc = Nokogiri::XML::Document.new
          node = doc.add_child("<task>")
          node.add_child("<#{options[:task].to_s + klass_name.camelize} />")
          node.child.add_child(options[:entity].to_xml.root)

          post.body = doc.to_xml(:encoding => "utf-8")

          xml = Nokogiri.XML(http.request(post).body)

          match = "#{options[:task].to_s + klass_name.camelize}Result";

          xsl = 
            "<xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">
            <xsl:template match=\"/tasksResponse\">
                <xsl:apply-templates />
            </xsl:template>
            <xsl:template match=\"text()\">
              <xsl:value-of select=\"normalize-space(.)\"/>
            </xsl:template>
            <xsl:template match=\"*[substring(name(), string-length(name()) - 5) = 'Result']\">
              <xsl:copy>
                <xsl:copy-of select=\"@*\" />
                  <xsl:apply-templates />
                </xsl:copy>
            </xsl:template>
            <xsl:template match=\"*\">
              <xsl:copy>
                <xsl:copy-of select=\"@*\" />
                <xsl:apply-templates />
              </xsl:copy>
            </xsl:template>
         </xsl:stylesheet>"

          #puts "pre transform:\n #{xml.to_s}"

          xslt = Nokogiri::XSLT.parse(xsl)
          xml = xslt.transform(xml)

          #puts "post transform:\n #{xml.to_s}"

          errors = nil

          # [CHRISK] wow! so many ways we can get errors presented
          unless xml.root.nil?
            if xml.root.name.eql? "errors"
              errors = xml.root.css("error").map() do |e|
                ErrorInfo.new(e)
              end
            elsif (!xml.root.child.nil?) && 
                  (xml.root.child.name.eql? "errors")
              errors = xml.root.child.css("error").map() do |e|
                ErrorInfo.new(e)
              end
            end
          end
         
          begin 
            klass_lookup = match.camelize
            klass = Saasu.const_get(klass_lookup.to_sym)
            result = klass.new(errors.nil? ? xml : nil)
          rescue NameError
            if (options[:task].eql? :update)
              result = UpdateResult.new(errors.nil? ? xml : nil)
            elsif (options[:task].eql? :insert)
              result = InsertResult.new(errors.nil? ? xml : nil)
            end
          end
          result.errors = errors
          result
        end

        def _delete(uid) 
          uri = URI.parse(request_path({:uid => uid}, false))
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true;
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE

          #puts "Request URL (DELETE) is #{uri.request_uri}"

          del = Net::HTTP::Delete.new(uri.request_uri)
          xml = Nokogiri.XML(http.request(del).body)
          xsl = 
            "<xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">
            <xsl:output method=\"html\" />
            <xsl:template match=\"/#{klass_name}Response\">
                <xsl:apply-templates />
            </xsl:template>
            <xsl:template match=\"*\">
              <xsl:copy>
                <xsl:copy-of select=\"@*\" />
                <xsl:apply-templates />
              </xsl:copy>
            </xsl:template>
         </xsl:stylesheet>"

          xslt = Nokogiri::XSLT.parse(xsl)
          xml = xslt.transform(xml)

          Saasu::DeleteResult.new(xml.root)
        end

        def query_string(options = {})
          options = defaults[:query_options].merge(options)
          options = auth_params().merge(options)
          url_encode_hash(options)
        end

        def auth_params()
          { :wsaccesskey => api_key, :fileuid => file_uid }
        end

        def url_encode_hash(hash = {})
          hash.map { |k, v| "#{k.to_s.gsub(/_/, "")}=#{(v.is_a? Date) ? v.to_saasu_iso8601 : v}"}.join("&")
        end
        
        def request_path(options = {}, all = true)
          path = (all == true ? defaults[:collection_name].sub(/Item/, "") : defaults[:resource_name])
          ENDPOINT + "/#{path}?#{query_string(options)}"
        end

        def task_path()
          ENDPOINT + "/Tasks?#{url_encode_hash(auth_params())}"
        end

        def klass_name()
          self.name.split("::")[1].camelize(:lower)
        end

    end
    
  end

end
