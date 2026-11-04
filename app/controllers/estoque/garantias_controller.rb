module Estoque
  class GarantiasController < BaseController
    def index
      @filtro = params[:filtro].presence || "ativas"
      @busca = params[:busca].to_s.strip

      itens_scope = Item
        .includes(:produto, :local)
        .references(:produto, :local)

      itens_scope = aplicar_filtro_garantia(itens_scope)

      if @busca.present?
        itens_scope = itens_scope.joins(:produto).where(
          "estoque_produtos.nome ILIKE :busca OR
           estoque_itens.codigo_patrimonio ILIKE :busca OR
           estoque_itens.numero_serie ILIKE :busca OR
           estoque_itens.mac ILIKE :busca OR
           estoque_itens.fornecedor_nome ILIKE :busca OR
           estoque_itens.nota_fiscal_numero ILIKE :busca",
          busca: "%#{@busca}%"
        )
      end

      itens_scope = itens_scope.order(data_compra: :desc, created_at: :desc)

      @itens_pagination = helpers.pagination_metadata(
        itens_scope,
        page: params[:page].presence || 1,
        per_page: 20
      )

      @itens = @itens_pagination[:records]

      carregar_totais
    end

    private

    def aplicar_filtro_garantia(scope)
      case @filtro
      when "ativas"
        scope.where(garantia_ativa_sql)
      when "vencendo"
        scope.where(garantia_vencendo_sql)
      when "vencidas"
        scope.where(garantia_vencida_sql)
      when "sem_data"
        scope.where(data_compra: nil)
      when "instalados"
        scope.where(status: :instalado)
      else
        scope
      end
    end

    def carregar_totais
      base = Item.all

      @total_ativas = base.where(garantia_ativa_sql).count
      @total_vencendo = base.where(garantia_vencendo_sql).count
      @total_vencidas = base.where(garantia_vencida_sql).count
      @total_sem_data = base.where(data_compra: nil).count
      @total_instalados = base.where(status: :instalado).count
    end

    def garantia_ativa_sql
      <<~SQL.squish
        estoque_itens.data_compra IS NOT NULL
        AND (
          (estoque_itens.data_compra + (estoque_itens.garantia_loja_dias * INTERVAL '1 day'))::date >= CURRENT_DATE
          OR
          (estoque_itens.data_compra + (estoque_itens.garantia_fabrica_meses * INTERVAL '1 month'))::date >= CURRENT_DATE
        )
      SQL
    end

    def garantia_vencendo_sql
      <<~SQL.squish
        estoque_itens.data_compra IS NOT NULL
        AND (
          (
            (estoque_itens.data_compra + (estoque_itens.garantia_loja_dias * INTERVAL '1 day'))::date
            BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
          )
          OR
          (
            (estoque_itens.data_compra + (estoque_itens.garantia_fabrica_meses * INTERVAL '1 month'))::date
            BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
          )
        )
      SQL
    end

    def garantia_vencida_sql
      <<~SQL.squish
        estoque_itens.data_compra IS NOT NULL
        AND
        (estoque_itens.data_compra + (estoque_itens.garantia_loja_dias * INTERVAL '1 day'))::date < CURRENT_DATE
        AND
        (estoque_itens.data_compra + (estoque_itens.garantia_fabrica_meses * INTERVAL '1 month'))::date < CURRENT_DATE
      SQL
    end
  end
end