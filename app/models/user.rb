class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { tecnico: 0, admin: 1 }, default: :tecnico

  has_many :historico_tecnicos, dependent: :destroy
  has_many :post_tecnicos, dependent: :destroy
  has_many :comentarios, dependent: :destroy
  has_many :checklists, dependent: :destroy

  validates :nome, presence: true

  def admin?
    role == "admin"
  end
end
