# +ApiListable+ module
module ApiListable
  extend ActiveSupport::Concern

  protected

  # renders a JSON response by instancing an +ApiListResource+ with the given
  # @param [ActiveRecord::Relation] collection - active record collection
  # @param [Array] search_fields - list of attributes to perform search filter
  # @param [Array] filtering_params - list of attributes to perform query filter
  # @return nil
  def render_json_api_list_resource(collection: nil, search_fields: nil,
                                    paginate: true, filtering_params: nil,
                                    response_args: {})
    resource = api_list_resource(collection: collection,
                                 search_fields: search_fields,
                                 paginate: paginate,
                                 filtering_params: filtering_params)
    render response_args.merge(
      json: resource.collection, meta: resource.meta_pagination
    )
  end

  # returns an +ApiListResource+ instance for the given +params+
  # @param [ActiveRecord::Relation] collection - active record collection
  # @param [Array] search_fields - list of attributes to perform search filter
  # @param [Array] filtering_params - list of attributes to perform query filter
  # @return nil
  def api_list_resource(collection: nil, search_fields: nil, paginate: true,
                        filtering_params: nil)
    ApiListResource.new(
      collection: collection,
      params: params,
      search_fields: search_fields,
      filtering_params: filtering_params,
      paginate: paginate
    )
  end

  # +ApiListResource+
  class ApiListResource
    # default page size for +kaminari+
    DEFAULT_PAGE_SIZE = 25

    module SortDirection
      ASC = 'asc'.freeze
      DESC = 'desc'.freeze

      LIST = { ASC => ASC, DESC => DESC }.freeze
    end

    attr_accessor :collection, :params, :search_fields, :filtering_params,
                  :paginate

    # constructor for +ApiListResource+.
    # Assigns all given +args+ and performs page, order, and search operations
    # to the shared collection
    # @return ApiListResource
    def initialize(args = {})
      args.each { |k, v| send("#{k}=", v) }
      page_collection!
      order_collection!
      search_collection!
      filter_collection!
    end

    # applies ActiveRecord scopes for the given +filtering_params+ HTTP values
    # Updates +collection+ attribute of the instance with the result.
    # @note Model should implement a filter scope for the whitelisted param
    # in compliance with +filter_<field>+ format
    # @return nil
    # @example
    # filtering_params[:name] -> Model#filter_name(args)
    def filter_collection!
      return if filtering_params.blank?

      filtering_params.each do |key, value|
        filter_key = "filter_#{key}"
        next if value.nil? || !collection.respond_to?(filter_key)

        self.collection = collection.public_send(filter_key, value)
      end
    end

    # applies ActiveRecord::Relation paging via +kaminari+ of the HTTP
    # +page+ params.
    # Updates +collection+ attribute of the instance with the result.
    # @return nil
    def page_collection!
      return unless paginate

      page = params[:page].to_i
      page = 1 if page.zero?
      page_size = params[:page_size].to_i
      page_size = DEFAULT_PAGE_SIZE if page_size <= 0
      self.collection = collection.page(page).per(page_size)
    end

    # applies ActiveRecord::Relation search via +ApiSearchResource+
    # of HTTP +globalSearch+ params.
    # Updates +collection+ attribute of the instance with the result.
    # @return nil
    def search_collection!
      return if search_fields.blank?

      query = params[:globalSearch]
      search_resource = ApiSearchResource.new(
        fields: search_fields
      )
      self.collection = search_resource.search!(collection, query)
    end

    # orders ActiveRecord::Relation order via HTTP +sort+ and +sortDirection+
    # params.
    # Updates +collection+ attribute of the instance with the result.
    # @return nil
    def order_collection!
      sort_field = (params[:sort] || '').underscore
      sort_direction_key = (params[:sortDirection] || '').downcase
      sort_direction = SortDirection::LIST[sort_direction_key]
      return if sort_field.blank? || sort_direction.blank?

      self.collection = collection.order(
        sort_field => sort_direction
      )
    end

    # return pagination meta information of the ActiveRecord::Relation
    # +collection+ instance attribute
    # @return nil
    def meta_pagination
      {
        itemsCount: collection.total_count,
        pagesCount: collection.total_pages
      }
    end
  end

  # +ApiSearchResource+
  class ApiSearchResource
    module Placeholder
      FIELD = '%FIELD%'.freeze
    end

    module Func
      UNACCENT = 'unaccent'.freeze
    end

    module Regex
      FIELD = ' '.freeze
      LIKE = 'ILIKE'.freeze
      OR = 'OR'.freeze
      WILDCARD = '%'.freeze
      ESCAPECHAR = '§'.freeze
      ESCAPE = /[!%_]/.freeze
    end

    module SearchType
      SEARCH_START = 1
      SEARCH_END = 2
    end

    attr_accessor :fields, :field_funcs

    # initializes an +ApiSearchResource+ instance and assigns all given
    # attributes.
    def initialize(args = {})
      args.each { |k, v| send("#{k}=", v) }
    end

    # returns a fully formatted DBMS specific function to filter values
    # depending on the instance +fields+ values.
    # For PostgreSQL, unaccent function is applied.
    # @return String
    def field_base
      @field_base ||= lambda do
        el = Placeholder::FIELD
        [Func::UNACCENT].each do |func|
          el = "#{func}(#{el})"
        end
        el
      end.call
    end

    # returns a fully formatted DBMS specific function to filter values
    # depending on the instance query value.
    # For PostgreSQL, unaccent function is applied.
    # @return String
    def query_base
      @query_base ||= lambda do
        el = '?'
        [Func::UNACCENT].each do |func|
          el = "#{func}(#{el})"
        end
        el
      end.call
    end

    # returns a Search DBMS specific query that slices the spaces of a
    # given +term+.
    # applies escape char to result so value specific queries can be performed.
    # @param [String] term - original search term string
    # @return String - updated search term
    def get_term(term)
      term = term.gsub(Regex::ESCAPE) { |x| "#{Regex::ESCAPECHAR}#{x}" }
      tmp = SearchType::SEARCH_START
      search_type = SearchType::SEARCH_START | SearchType::SEARCH_END

      term = "#{Regex::WILDCARD}#{term}" if (search_type | tmp) == search_type
      tmp = SearchType::SEARCH_END
      term << Regex::WILDCARD if (search_type | tmp) == search_type
      term
    end

    # returns a Search DBMS specific field depending on the instance +table+
    # and +field+ values.
    # this field will be used if search is performed in a join context when
    # the table name is prepended for DBMS search support.
    # @param [Object] field - Hash or String
    # @return String - search field result
    def get_field(field, collection)
      if field.is_a?(Hash) # rubocop:disable Style/ConditionalAssignment
        field = "#{field[:table]}.#{field[:field]}"
      else
        field = "#{collection.table_name}.#{field}"
      end
      field_base.gsub(Placeholder::FIELD, field)
    end

    # performs a search DBMS operation via +ActiveRecord::Relation+ interface.
    # The search result will contain an optimal DBMS search operation and
    # modify the instance's +collection+ attribute
    # @param [ActiveRecord::Relation] collection - Original collection
    # @param [String] query_str - Search query term
    # @return ActiveRecord::Relation - search results modified collection
    def search!(collection, query_str)
      res = collection
      if query_str.present?
        parts = []
        terms = []
        query_str.split(Regex::FIELD).each do |term|
          next if term.blank?

          fields.each do |f|
            field = get_field(f, collection)
            part = ["#{field} #{Regex::LIKE} ",
                    "#{query_base} ESCAPE '#{Regex::ESCAPECHAR}'"].join('')
            terms << get_term(term)
            parts << part
          end
        end

        if parts.any?
          query = parts.join(" #{Regex::OR} ")
          res = res.where(query, *terms)
        end
      end
      res
    end
  end
end
