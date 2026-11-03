
class HistoricoTecnico < ApplicationRecord
  belongs_to :condominio
  belongs_to :equipamento, optional: true
  belongs_to :user

  enum :tipo, {
    preventiva: 0,
    corretiva: 1,
    instalacao: 2,
    inspecao: 3
  }, default: :corretiva

  enum :status, {
    concluido: 0,
    em_andamento: 1,
    pendente: 2
  }, default: :concluido

  # Fotos do atendimento
  has_many_attached :fotos

  FORMATOS_FOTOS = %w[
    image/jpeg
    image/png
    image/webp
  ].freeze

  MAX_FOTOS = 10
  MAX_TAMANHO_FOTO = 10.megabytes

  validates :titulo, :descricao, :data_atendimento,
    presence: true

  validate :validar_fotos
  validate :validar_equipamento_do_condominio

  scope :recentes, -> {
    order(data_atendimento: :desc)
  }

  private

  # Garante que o equipamento pertence
  # ao condomínio do atendimento.
  def validar_equipamento_do_condominio
    return if equipamento_id.blank?
    return if condominio_id.blank?

    unless Equipamento.exists?(
      id: equipamento_id,
      condominio_id: condominio_id
    )
      errors.add(
        :equipamento,
        "não pertence a este condomínio"
      )
    end
  end

  def validar_fotos
    anexos = fotos.blobs.to_a

    if anexos.size > MAX_FOTOS
      errors.add(
        :fotos,
        "permitem no máximo #{MAX_FOTOS} imagens"
      )
    end

    anexos.each do |arquivo|
      unless FORMATOS_FOTOS.include?(arquivo.content_type)
        errors.add(
          :fotos,
          "#{arquivo.filename} possui formato inválido. " \
          "Use JPG, PNG ou WebP."
        )
      end

      if arquivo.byte_size > MAX_TAMANHO_FOTO
        errors.add(
          :fotos,
          "#{arquivo.filename} ultrapassa 10 MB"
        )
      end
    end
  end
end
