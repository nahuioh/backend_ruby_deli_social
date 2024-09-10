class Account < ApplicationRecord
  # Validaciones, asociaciones, etc.
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
  # Puedes añadir más validaciones aquí si es necesario
end
