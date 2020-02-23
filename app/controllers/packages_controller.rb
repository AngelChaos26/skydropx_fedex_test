# Fedex Package API Endpoints
#
class PackagesController < ApplicationController
  # Fetches a given +Package+ element
  # @return [Array] JSON array of all +Packages+ elements
  def index
    result = Package.render_packages!
    json_response(result)
  end
end
