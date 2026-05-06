class Curtida < ApplicationRecord
  belongs_to :post_tecnico
  belongs_to :user

  validates :user_id, uniqueness: { scope: :post_tecnico_id }
end
