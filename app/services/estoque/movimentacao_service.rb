
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

        quantidade = converter_quantidade(
          @params[:quantidade]
        )

        origem = find_local(
          @params[:origem_local_id]
        )

        destino = find_local(
          @params[:destino_local_id]
        )

        # Valida tudo antes de movimentar os saldos.
        validar_locais!(tipo, origem, destino)

        case tipo
        when "entrada"
          entrada(produto, destino, quantidade)

        when "saida", "perda", "defeito", "uso_servico"
          saida(produto, origem, quantidade)

        when "transferencia", "devolucao"
          transferencia(
            produto,
            origem,
            destino,
            quantidade,
            tipo
          )

        when "ajuste", "inventario"
          ajustar_saldo(
            produto,
            destino,
            quantidade,
            tipo
          )

        else
          raise ArgumentError,
            "Tipo de movimentação inválido."
        end
      end
    end

    private

    # =========================================
    # CONVERSÃO E VALIDAÇÕES
    # =========================================

    def converter_quantidade(valor)
      quantidade = BigDecimal(valor.to_s)

      unless quantidade.finite? && quantidade.positive?
        raise ArgumentError,
          "Quantidade precisa ser maior que zero."
      end

      quantidade
    rescue ArgumentError, TypeError
      raise ArgumentError,
        "Informe uma quantidade numérica maior que zero."
    end

    def find_local(id)
      return nil if id.blank?

      Local.find(id)
    end

    def validar_locais!(tipo, origem, destino)
      case tipo
      when "entrada", "ajuste", "inventario"
        if destino.nil?
          raise ArgumentError,
            "Selecione o estoque de destino."
        end

      when "saida", "perda", "defeito", "uso_servico"
        if origem.nil?
          raise ArgumentError,
            "Selecione o estoque de origem."
        end

      when "transferencia", "devolucao"
        if origem.nil?
          raise ArgumentError,
            "Selecione o estoque de origem."
        end

        if destino.nil?
          raise ArgumentError,
            "Selecione o estoque de destino."
        end

        if origem.id == destino.id
          raise ArgumentError,
            "Transferência inválida: o estoque de destino deve ser diferente do estoque de origem."
        end
      end
    end

    # =========================================
    # SALDOS
    # =========================================

    def saldo_for(produto, local)
      if local.nil?
        raise ArgumentError,
          "Estoque/local não informado."
      end

      # Aproveita a restrição UNIQUE já existente
      # para produto + local.
      saldo = Saldo.create_or_find_by!(
        produto: produto,
        local: local
      )

      # Bloqueia o saldo durante a alteração.
      saldo.lock!

      saldo
    end

    # =========================================
    # ENTRADA
    # =========================================

    def entrada(produto, destino, quantidade)
      saldo_destino = saldo_for(produto, destino)

      antes = saldo_destino.quantidade
      depois = antes + quantidade

      saldo_destino.update!(
        quantidade: depois
      )

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

    # =========================================
    # SAÍDA
    # =========================================

    def saida(produto, origem, quantidade)
      saldo_origem = saldo_for(produto, origem)

      antes = saldo_origem.quantidade
      depois = antes - quantidade

      if depois.negative?
        raise ArgumentError,
          "Saldo insuficiente no estoque de origem."
      end

      saldo_origem.update!(
        quantidade: depois
      )

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

    # =========================================
    # TRANSFERÊNCIA E DEVOLUÇÃO
    # =========================================

    def transferencia(
      produto,
      origem,
      destino,
      quantidade,
      tipo
    )
      # Segunda proteção, próxima da operação.
      if origem.nil? || destino.nil?
        raise ArgumentError,
          "Origem e destino são obrigatórios."
      end

      if origem.id == destino.id
        raise ArgumentError,
          "Não é permitido transferir materiais para o próprio estoque."
      end

      saldo_origem = saldo_for(produto, origem)

      origem_antes = saldo_origem.quantidade
      origem_depois = origem_antes - quantidade

      if origem_depois.negative?
        raise ArgumentError,
          "Saldo insuficiente no estoque de origem."
      end

      # A origem é descontada imediatamente.
      saldo_origem.update!(
        quantidade: origem_depois
      )

      # O destino só recebe o saldo após
      # a confirmação do recebimento.
      Movimentacao.create!(
        produto: produto,
        origem_local: origem,
        destino_local: destino,
        user: @user,
        tipo: tipo,
        quantidade: quantidade,
        saldo_origem_antes: origem_antes,
        saldo_origem_depois: origem_depois,
        saldo_destino_antes: nil,
        saldo_destino_depois: nil,
        status_recebimento: :pendente,
        observacao: @params[:observacao]
      )
    end

    # =========================================
    # AJUSTE E INVENTÁRIO
    # =========================================

    def ajustar_saldo(
      produto,
      destino,
      nova_quantidade,
      tipo
    )
      saldo_destino = saldo_for(produto, destino)

      antes = saldo_destino.quantidade
      depois = nova_quantidade

      saldo_destino.update!(
        quantidade: depois
      )

      Movimentacao.create!(
        produto: produto,
        destino_local: destino,
        user: @user,
        tipo: tipo,
        quantidade: nova_quantidade,
        saldo_destino_antes: antes,
        saldo_destino_depois: depois,
        observacao: @params[:observacao]
      )
    end
  end
end
