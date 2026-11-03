module Estoque
  class LocalResponsavel < ApplicationRecord
    self.table_name = "estoque_local_responsaveis"

    belongs_to :local, class_name: "Estoque::Local"
    belongs_to :user

    validates :user_id, uniqueness: { scope: :local_id }
  end
end