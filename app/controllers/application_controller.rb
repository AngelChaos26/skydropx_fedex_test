# Base Application Controller definition. Contains shared methods and concerns.
#
class ApplicationController < ActionController::API
  include ApiListable

  protected

  # serialized the given ruby +Object+ to a JSON response for an optional
  # HTTP +status+ attribute.
  # When this method is called, response is terminated.
  # @return nil
  def json_response(object, status = :ok, args = {})
    args = {} if args.nil?
    args[:status] = status
    args[:json] = object
    render args
  end
end
