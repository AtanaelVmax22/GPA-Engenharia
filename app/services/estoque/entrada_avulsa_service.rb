
require "securerandom"

module Estoque
  class EntradaAvulsaService
    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def call
      ActiveRecord::Base.transaction do
        produto = Produto.find(@params[:produto_id])
        local = Local.find(@params[:local_id])

        unless local.condominio? &&
               local.condominio_id.present? &&
               local.ativo?
          raise ArgumentError,
            "Selecione um condomínio com estoque ativo."
        end

        unless produto.ativo?
          raise ArgumentError, "O produto está inativo."
        end

        autorizar!(local.condominio_id)

        # O patrimônio GPA identifica o item
        # independentemente da série do fabricante.
        patrimonio = @params[:codigo_patrimonio]
          .to_s.strip.upcase

        patrimonio = gerar_patrimonio if patrimonio.blank?

        serie = @params[:numero_serie]
          .to_s.strip.presence

        item = Item.create!(
          produto: produto,
          local: local,
          condominio_id: local.condominio_id,
          status: :em_estoque,
          codigo_patrimonio: patrimonio,
          numero_serie: serie,
          mac: @params[:mac],
          data_compra: @params[:data_compra],
          fornecedor_nome: @params[:fornecedor_nome],
          nota_fiscal_numero: @params[:nota_fiscal_numero],
          garantia_loja_dias: @params[:garantia_loja_dias],
          garantia_fabrica_meses: @params[:garantia_fabrica_meses],
          observacao: @params[:observacao]
        )

        saldo = Saldo.create_or_find_by!(
          produto: produto,
          local: local
        )

        saldo.lock!

        antes = saldo.quantidade
        depois = antes + 1

        saldo.update!(quantidade: depois)

        movimentacao = Movimentacao.create!(
          produto: produto,
          destino_local: local,
          user: @user,
          tipo: :entrada,
          quantidade: 1,
          status_recebimento: :nao_aplicavel,
          saldo_destino_antes: antes,
          saldo_destino_depois: depois,
          observacao: [
            "Entrada direta de fornecedor.",
            "Patrimônio GPA: #{item.codigo_patrimonio}.",
            @params[:observacao].presence
          ].compact.join(" ")
        )

        MovimentacaoItem.create!(
          movimentacao: movimentacao,
          item: item
        )

        item
      end
    end

    private

    def gerar_patrimonio
      loop do
        codigo = "GPA-#{SecureRandom.hex(8).upcase}"

        return codigo unless Item.exists?(
          codigo_patrimonio: codigo
        )
      end
    end

    def autorizar!(condominio_id)
      permitido =
        @user&.admin? ||
        (
          @user&.tecnico? &&
          CondominioTecnico.exists?(
            condominio_id: condominio_id,
            user_id: @user.id
          )
        )

      unless permitido
        raise ArgumentError,
          "Você não está autorizado a registrar equipamentos neste condomínio."
      end
    end
  end
end
