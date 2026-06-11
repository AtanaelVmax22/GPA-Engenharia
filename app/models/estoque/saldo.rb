module Estoque
  class Saldo < ApplicationRecord
    self.table_name = "estoque_saldos"

    belongs_to :produto, class_name: "Estoque::Produto"
    belongs_to :local, class_name: "Estoque::Local"

    validates :quantidade, numericality: { greater_than_or_equal_to: 0 }
    validates :produto_id, uniqueness: { scope: :local_id }
  end
end