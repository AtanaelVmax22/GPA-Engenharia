module Estoque
  class MovimentacaoService
    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def call
      ActiveRecord::Base.transaction do
        produto = Produto.find(@params[:produto_id])
        tipo = @params[:tipo].to_s
        quantidade = BigDecimal(@params[:quantidade].to_s)

        raise ArgumentError, "Quantidade precisa ser maior que zero." if quantidade <= 0

        origem = find_local(@params[:origem_local_id])
        destino = find_local(@params[:destino_local_id])

        case tipo
        when "entrada"
          entrada(produto, destino, quantidade)

        when "saida", "perda", "defeito", "uso_servico"
          saida(produto, origem, quantidade)

        when "transferencia", "devolucao"
          transferencia(produto, origem, destino, quantidade)

        when "ajuste", "inventario"
          ajustar_saldo(produto, destino, quantidade)

        else
          raise ArgumentError, "Tipo de movimentação inválido."
        end
      end
    end

    private

    def find_local(id)
      return nil if id.blank?

      Local.find(id)
    end

    def saldo_for(produto, local)
      raise ArgumentError, "Estoque/local não informado." if local.blank?

      saldo = Saldo.find_or_create_by!(produto: produto, local: local)
      saldo.lock!
      saldo
    end

    def entrada(produto, destino, quantidade)
      saldo_destino = saldo_for(produto, destino)

      antes = saldo_destino.quantidade
      depois = antes + quantidade

      saldo_destino.update!(quantidade: depois)

      Movimentacao.create!(
        produto: produto,
        destino_local: destino,
        user: @user,
        tipo: :entrada,
        quantidade: quantidade,
        saldo_destino_antes: antes,
        saldo_destino_depois: depois,
        observacao: @params[:observacao]
      )
    end

    def saida(produto, origem, quantidade)
      saldo_origem = saldo_for(produto, origem)

      antes = saldo_origem.quantidade
      depois = antes - quantidade

      raise ArgumentError, "Saldo insuficiente no estoque de origem." if depois.negative?

      saldo_origem.update!(quantidade: depois)

      Movimentacao.create!(
        produto: produto,
        origem_local: origem,
        user: @user,
        tipo: @params[:tipo],
        quantidade: quantidade,
        saldo_origem_antes: antes,
        saldo_origem_depois: depois,
        observacao: @params[:observacao]
      )
    end

    def transferencia(produto, origem, destino, quantidade)
  raise ArgumentError, "Estoque de origem e destino não podem ser iguais." if origem == destino

  saldo_origem = saldo_for(produto, origem)

  origem_antes = saldo_origem.quantidade
  origem_depois = origem_antes - quantidade

  raise ArgumentError, "Saldo insuficiente no estoque de origem." if origem_depois.negative?

  saldo_origem.update!(quantidade: origem_depois)

  Movimentacao.create!(
    produto: produto,
    origem_local: origem,
    destino_local: destino,
    user: @user,
    tipo: @params[:tipo],
    quantidade: quantidade,
    saldo_origem_antes: origem_antes,
    saldo_origem_depois: origem_depois,
    saldo_destino_antes: nil,
    saldo_destino_depois: nil,
    status_recebimento: :pendente,
    observacao: @params[:observacao]
  )
end

    def ajustar_saldo(produto, destino, nova_quantidade)
      saldo_destino = saldo_for(produto, destino)

      antes = saldo_destino.quantidade
      depois = nova_quantidade

      saldo_destino.update!(quantidade: depois)

      Movimentacao.create!(
        produto: produto,
        destino_local: destino,
        user: @user,
        tipo: @params[:tipo],
        quantidade: nova_quantidade,
        saldo_destino_antes: antes,
        saldo_destino_depois: depois,
        observacao: @params[:observacao]
      )
    end
  end
end