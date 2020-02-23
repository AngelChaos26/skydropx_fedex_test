# +PackageSerializer+ Serializer
class PackageSerializer < ActiveModel::Serializer
  attributes :tracking_number,
             :package_weight,
             :fedex_weight,
             :overweight,
             :message
end
