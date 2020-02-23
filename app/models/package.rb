# This class represents a Package based in a JSON file
class Package
  include ActiveModel::Model
  include ActiveModel::Serialization
  include Fedexable
  # Virtual attributes
  attr_accessor :tracking_number, :package_weight, :fedex_weight, :overweight,
                :message

  # enum modules
  module MassUnit
    KG = :kg
    LB = :lb
    DATA = {
      KG => {
        value: 1.0
      },
      LB => {
        value: 0.453592
      }
    }.freeze
    LIST = [KG, LB].freeze
  end

  module DistanceUnit
    CM = :cm
    IN = :in
    DATA = {
      CM => {
        value: 1.0
      },
      IN => {
        value: 2.54
      }
    }.freeze
    LIST = [CM, IN].freeze
  end

  module VolumetricUnit
    CM = :cm
    IN = :in
    DATA = {
      CM => {
        value: 5000.0
      },
      IN => {
        value: 166.0
      }
    }.freeze
    LIST = [CM, IN].freeze
  end

  # Returns a list of +Packages+ stored at a JSON file, then track the
  #   package using Fedex API
  # @return [Array] JSON Array of all packages available
  def self.render_packages!
    packages = read_packages!
    response = []
    packages.each do |package|
      total_weight = package_total_weight package['parcel']
      label_total_weight = total_weight.ceil
      fedex_total_weight = fedex_total_weight package['tracking_number']
      next if fedex_total_weight.nil?

      overweight = (fedex_total_weight - label_total_weight).ceil
      message = ('La etiqueta no incurrio en sobrepeso' if overweight <= 0)
      response.push(Package.new(tracking_number: package['tracking_number'],
                                package_weight: label_total_weight,
                                fedex_weight: fedex_total_weight,
                                overweight: overweight,
                                message: message))
    end

    response
  end

  # Returns an array with packages delivery information from .json file
  # @raise Errno::ENOENT []
  # @return [Array] JSON Array with packages from file
  def self.read_packages!
    packages = File.read(package_file)
    JSON.parse(packages)
  rescue Errno::ENOENT
    []
  end

  # Calculates total weight from platform package calculating weigth and
  #   volumetric weight
  # @return Decimal
  def self.package_total_weight(parcel)
    weight = calculate_weight parcel['weight'].to_f, parcel['mass_unit']
    volumetric_weight = calculate_volumetric_weight parcel['length'].to_f,
                                                    parcel['width'].to_f,
                                                    parcel['height'].to_f,
                                                    parcel['distance_unit']

    weight > volumetric_weight ? weight : volumetric_weight
  end

  # Calculates total weight from fedex tracking package using the details
  #   provided from fedex API, calculating from package_weight and
  #   package_dimensions for volumetric weight
  # @raise Fedex::RateError nil
  # @return Decimal
  def self.fedex_total_weight(tracking_number)
    result = fedex_client.track(tracking_number: tracking_number)
    package = result.first
    return if package.nil?

    weight = if package.details[:package_weight].present?
               calculate_weight package.details[:package_weight][:value].to_f,
                                package.details[:package_weight][:units]
             else
               0.0
             end
    volumetric_weight = if package.details[:package_dimensions].present?
                          dimension = package.details[:package_dimensions]
                          calculate_volumetric_weight dimension[:length].to_f,
                                                      dimension[:width].to_f,
                                                      dimension[:height].to_f,
                                                      dimension[:units]
                        else
                          0.0
                        end
    weight > volumetric_weight ? weight : volumetric_weight
  rescue Fedex::RateError
    nil
  end

  # Calculates weight based in a mass unit, converts the weight to KG
  # @return Decimal
  def self.calculate_weight(weight, unit)
    unit = unit.downcase
    weight * MassUnit::DATA[unit.to_sym][:value]
  end

  # Calculates weight based in a distance unit, converts the weight to KG
  # Converts the volumetric weight to CM
  # @return Decimal
  def self.calculate_volumetric_weight(length, width, height, unit)
    unit = unit.downcase
    volumetric_weight =
      (length * width * height) / VolumetricUnit::DATA[unit.to_sym][:value]
    volumetric_weight * DistanceUnit::DATA[unit.to_sym][:value]
  end

  # Returns the route of the json file provided by the env var
  # @return String
  def self.package_file
    ENV['PACKAGES_FILE']
  end
end
