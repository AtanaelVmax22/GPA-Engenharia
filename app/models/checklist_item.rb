class ChecklistItem < ApplicationRecord
  belongs_to :checklist

  validates :descricao, presence: true
  default_scope { order(:ordem) }
end
