# configure ransack to raise exception,
# for development only
if Rails.env.development?
  Ransack.configure do |config|
    # Raise errors if a query contains an unknown predicate or attribute.
    # Default is true (do not raise error on unknown conditions).
    config.ignore_unknown_conditions = false
  end
end
