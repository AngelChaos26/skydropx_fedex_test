# Base Application Job definition. Defines shared methods and concerns.
#
class ApplicationJob < ActiveJob::Base
  include Errorable

  # dummy method definition for +Errorable+ support.
  # logs the resulting error to rails logger.
  # @return nil
  def json_response(*args)
    object = args.first || {}
    Rails.logger.debug object.to_s
  end
end
