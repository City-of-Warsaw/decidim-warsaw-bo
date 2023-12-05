# frozen_string_literal: true

module LoaderFixture
  extend self

  def load_fixture_yaml(filename, **options)
    raise ArgumentError, "Filename must end with '.yml'" unless filename.end_with?('.yml')

    YAML.safe_load(
      load_fixture(filename),
      { symbolize_names: true }.merge(options)
    )
  end

  private

  def load_fixture(filename)
    File.read(Rails.root.join('spec', 'fixtures', filename))
  end
end
