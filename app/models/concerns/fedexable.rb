# +Fedexable+ module.
module Fedexable
  extend ActiveSupport::Concern
  included do
    # returns an instance of a +Fedex::Shipment+ class initialized with the
    #   given ENV variables
    # @return Fedex::Shipment
    def self.fedex_client
      @fedex_client ||=
        Fedex::Shipment.new(key: ENV['FEDEX_KEY'],
                            password: ENV['FEDEX_PASSWORD'],
                            account_number: ENV['FEDEX_ACCOUNT'],
                            meter: ENV['FEDEX_METER'],
                            mode: ENV['FEDEX_MODE'])
    end
  end
end
