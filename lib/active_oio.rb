require 'rubygems'
require 'activeresource'

module ActiveOIO
  class Base < ActiveResource::Base




    self.site = 'http://oiorest.dk/danmark/'

#    self.logger = Logger.new(STDOUT)
    self.logger = Logger.new('log/oiorest.log', 0, 10000000)





    class << self



      def find(*arguments)
        scope   = arguments.slice!(0)
        options = arguments.slice!(0) || {}

        case scope
          when :all   then find_every(options)
          when :first then find(find_every(options).first.to_param)
          when :one   then find_one(options)
          else             find_single(scope, options)
        end
      end


      ## remove .xml from the url
      def element_path(id, prefix_options = {}, query_options = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}#{collection_name}/#{id}#{query_string(query_options)}"
      end

      ## Remove .xml from the url.
      def collection_path(prefix_options = {}, query_options = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
      end

      ## this method override makes it possible to retrieve arrays of results
      def instantiate_collection(collection, prefix_options = {})
        ## collection with timestamps
        if collection.size == 3
          value = collection.values[1]
          ## collection without timestamp
        elsif collection.size ==2
          value = collection.values[0]
        elsif collection.size == 4
          value = collection
        end
        if(value.is_a? Array)
          # Assume the value contains an array of elements to create
          return value.collect!  { |record| instantiate_record(record, prefix_options) }
        elsif(value.is_a? Hash) # search results
          result = []
          result << instantiate_record(value, prefix_options)
        end
      end
    end
  end
end
