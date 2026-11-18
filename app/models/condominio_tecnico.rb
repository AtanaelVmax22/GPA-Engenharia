
class CondominioTecnico < ApplicationRecord
  self.table_name = "condominio_tecnicos"

  belongs_to :condominio
  belongs_to :user

  validates :user_id, uniqueness: {
    scope: :condominio_id
  }
end
