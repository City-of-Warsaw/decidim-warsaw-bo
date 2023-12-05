# frozen_string_literal: true

Decidim::Attachment.class_eval do
  attr_accessor :new_file_name

  validates :file,
            file_size: { greater_than_or_equal_to: 1.bytes.to_i, message: 'Rozmiar pliku musi być większy niż 0 bajtów.' }

  scope :scans,     -> { where(eval_file_type: 'scan') }
  scope :available, -> { where(eval_file_type: 'available') }
end