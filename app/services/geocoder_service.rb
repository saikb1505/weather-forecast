class GeocoderService
  require 'geocoder'

  def self.fetch_zip_code(address)
    return nil if address.blank?
    
    location = Geocoder.search(address)&.first
    return nil unless location && location.postal_code.present?

    [location.postal_code, location.data['lat'], location.data['lon']]
  rescue StandardError => e
    Rails.logger.error "Geocoder Error: #{e.message}"
    nil
  end
end