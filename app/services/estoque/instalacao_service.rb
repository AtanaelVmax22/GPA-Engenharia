
module Estoque
  class InstalacaoService
    def initialize(user:, item_id:, condominio:,
                   local_instalacao:, data_instalacao:,
                   observacao: nil)
      @user = user
      @item_id = item_id
      @condominio = condominio
      @local_instalacao = local_instalacao.to_s.strip
      @data_instalacao = data_instalacao
      @observacao = observacao.to_s.strip
    end

    def call
      validar_autorizacao!

      ActiveRecord::Base.transaction do
        item = Item.find(@item_id)
        item.lock!

        local = @condominio.local_estoque

        unless local&.ativo? && local.condominio?
          raise ArgumentError,
            "O condomínio não possui um estoque ativo."
        end

        unless item.local_id == local.id &&
               item.condominio_id == @condominio.id
          raise ArgumentError,
            "Este equipamento não pertence ao condomínio."
        end

        unless item.em_estoque?
          raise ArgumentError,
            "O equipamento não está disponível para instalação."
        end

        if @local_instalacao.blank?
          raise ArgumentError,
            "Informe o local exato da instalação."
        end

        data = Date.iso8601(@data_instalacao.to_s)

        if data > Date.current
          raise ArgumentError,
            "A data de instalação não pode ser futura."
        end

        saldo = Saldo.find_by(
          produto: item.produto,
          local: local
        )

        raise ArgumentError,
          "Não existe saldo disponível para este equipamento." unless saldo

        saldo.lock!

        if saldo.quantidade < 1
          raise ArgumentError,
            "Saldo insuficiente para instalar o equipamento."
        end

        saldo_antes = saldo.quantidade
        saldo_depois = saldo_antes - 1

        saldo.update!(quantidade: saldo_depois)

        movimentacao = Movimentacao.create!(
          produto: item.produto,
          origem_local: local,
          user: @user,
          tipo: :uso_servico,
          quantidade: 1,
          status_recebimento: :nao_aplicavel,
          saldo_origem_antes: saldo_antes,
          saldo_origem_depois: saldo_depois,
          observacao: [
            "Instalação no condomínio #{@condominio.nome}.",
            "Patrimônio: #{item.identificacao}.",
            "Local: #{@local_instalacao}.",
            @observacao.presence
          ].compact.join(" ")
        )

        MovimentacaoItem.create!(
          movimentacao: movimentacao,
          item: item
        )

        item.update!(
          status: :instalado,
          condominio_id: @condominio.id,
          data_instalacao: data,
          local_instalacao: @local_instalacao,
          instalado_por_id: @user.id
        )

        item
      end
    rescue Date::Error
      raise ArgumentError,
        "Informe uma data de instalação válida."
    end

    private

    def validar_autorizacao!
      permitido =
        @user&.admin? ||
        (
          @user&.tecnico? &&
          CondominioTecnico.exists?(
            condominio_id: @condominio.id,
            user_id: @user.id
          )
        )

      raise ArgumentError,
        "Usuário não autorizado neste condomínio." unless permitido
    end
  end
end
