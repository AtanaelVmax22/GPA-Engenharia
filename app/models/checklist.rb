class Checklist < ApplicationRecord
  belongs_to :condominio
  belongs_to :user

  enum :status, { em_andamento: 0, concluido: 1 }, default: :em_andamento

  has_many :checklist_items, dependent: :destroy
  accepts_nested_attributes_for :checklist_items, allow_destroy: true

  validates :titulo, presence: true

  def progresso
    return 0 if checklist_items.empty?
    concluidos = checklist_items.where(concluido: true).count
    (concluidos.to_f / checklist_items.count * 100).round
  end
end
