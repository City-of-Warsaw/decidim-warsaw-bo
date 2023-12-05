# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password, :first_name, :last_name, :email, :phone_number, :street,
                                               :street_number, :flat_number, :zip_code, :city]
