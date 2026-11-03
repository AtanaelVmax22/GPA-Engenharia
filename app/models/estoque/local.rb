module Estoque
  class Local < ApplicationRecord
    self.table_name = "estoque_locais"

    enum :tipo, {
      central: 0,
      regional: 1,
      tecnico: 2,
      veiculo: 3,
      obra: 4,
      condominio: 5,
      descarte: 6
    }

    belongs_to :responsavel, class_name: "User", optional: true

    has_many :saldos,
      class_name: "Estoque::Saldo",
      foreign_key: :local_id,
      dependent: :destroy

    has_many :movimentacoes_origem,
      class_name: "Estoque::Movimentacao",
      foreign_key: :origem_local_id,
      dependent: :nullify

    has_many :movimentacoes_destino,
      class_name: "Estoque::Movimentacao",
      foreign_key: :destino_local_id,
      dependent: :nullify

    has_many :local_responsaveis,
      class_name: "Estoque::LocalResponsavel",
      foreign_key: :local_id,
      dependent: :destroy

    has_many :responsaveis,
      through: :local_responsaveis,
      source: :user

    before_validation :generate_qr_token, on: :create
    after_save :sincronizar_responsaveis_multiplos, if: :responsavel_ids_para_salvar_definido?

    validates :nome, presence: true
    validates :tipo, presence: true
    validates :qr_token, presence: true, uniqueness: true

    validate :limite_de_responsaveis

    scope :ativos, -> { where(ativo: true) }

    def responsavel_ids
      if responsavel_ids_para_salvar_definido?
        @responsavel_ids_para_salvar
      else
        ids = responsaveis.pluck(:id)

        if ids.empty? && responsavel_id.present?
          ids = [responsavel_id]
        end

        ids
      end
    end

    def responsavel_ids=(ids)
      @responsavel_ids_para_salvar = Array(ids)
        .reject(&:blank?)
        .map(&:to_i)
        .uniq
    end

    private

    def generate_qr_token
      self.qr_token ||= SecureRandom.hex(16)
    end

    def responsavel_ids_para_salvar_definido?
      defined?(@responsavel_ids_para_salvar)
    end

    def limite_de_responsaveis
      ids =
        if responsavel_ids_para_salvar_definido?
          @responsavel_ids_para_salvar
        else
          responsaveis.map(&:id).compact.uniq
        end

      if ids.size > 3
        errors.add(:responsaveis, "permite no máximo 3 responsáveis")
      end
    end

    def sincronizar_responsaveis_multiplos
      ids = @responsavel_ids_para_salvar

      local_responsaveis.where.not(user_id: ids).destroy_all

      ids.each do |user_id|
        local_responsaveis.find_or_create_by!(user_id: user_id)
      end

      responsavel_principal_id = ids.first

      if responsavel_id != responsavel_principal_id
        update_column(:responsavel_id, responsavel_principal_id)
      end
    end
  end
end