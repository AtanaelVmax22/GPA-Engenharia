module Estoque
  class RecebimentosController < BaseController
    before_action :set_local, only: [:index]
    before_action :set_movimentacao, only: [:show, :confirmar, :recusar]

    def index
      @pendentes = Movimentacao
        .includes(:produto, :origem_local, :destino_local, :user)
        .where(destino_local: @local, tipo: :transferencia, status_recebimento: :pendente)
        .order(created_at: :desc)
    end

    def show
    end

    def confirmar
  qr_token_informado = extrair_qr_token(params[:qr_token_produto])
  recebimento_manual = params[:recebimento_manual].to_s == "1"
  observacao = params[:observacao_recebimento].to_s.strip

  if qr_token_informado.blank? && !recebimento_manual
    redirect_to estoque_recebimento_path(@movimentacao),
      alert: "Leia o QR Code do produto ou marque recebimento manual por conferência visual."
    return
  end

  if recebimento_manual && observacao.length < 10
    redirect_to estoque_recebimento_path(@movimentacao),
      alert: "Para recebimento manual, informe uma observação com pelo menos 10 caracteres explicando a conferência."
    return
  end

  if qr_token_informado.present? && qr_token_informado != @movimentacao.produto.qr_token
    redirect_to estoque_recebimento_path(@movimentacao),
      alert: "QR Code inválido. O QR informado não pertence ao produto desta transferência."
    return
  end

  ActiveRecord::Base.transaction do
    raise ArgumentError, "Esta transferência já foi recebida." unless @movimentacao.pendente?

    saldo_destino = Saldo.find_or_create_by!(
      produto: @movimentacao.produto,
      local: @movimentacao.destino_local
    )

    saldo_destino.lock!

    destino_antes = saldo_destino.quantidade
    destino_depois = destino_antes + @movimentacao.quantidade

    saldo_destino.update!(quantidade: destino_depois)

    observacao_final =
      if recebimento_manual
        "[RECEBIMENTO MANUAL POR CONFERÊNCIA VISUAL] #{observacao}"
      else
        observacao
      end

    @movimentacao.update!(
      status_recebimento: :recebido,
      recebido_por: current_user,
      recebido_em: Time.current,
      observacao_recebimento: observacao_final,
      qr_produto_confirmado_token: qr_token_informado.presence,
      qr_produto_confirmado_em: qr_token_informado.present? ? Time.current : nil,
      saldo_destino_antes: destino_antes,
      saldo_destino_depois: destino_depois
    )
  end

  redirect_to estoque_local_path(@movimentacao.destino_local),
    notice: "Transferência recebida e adicionada ao estoque com sucesso."
rescue ArgumentError, ActiveRecord::RecordInvalid => e
  redirect_to estoque_recebimento_path(@movimentacao),
    alert: e.message
end

    def recusar
      ActiveRecord::Base.transaction do
        raise ArgumentError, "Esta transferência já foi processada." unless @movimentacao.pendente?

        saldo_origem = Saldo.find_or_create_by!(
          produto: @movimentacao.produto,
          local: @movimentacao.origem_local
        )

        saldo_origem.lock!

        origem_antes = saldo_origem.quantidade
        origem_depois = origem_antes + @movimentacao.quantidade

        saldo_origem.update!(quantidade: origem_depois)

        @movimentacao.update!(
          status_recebimento: :recusado,
          recebido_por: current_user,
          recebido_em: Time.current,
          observacao_recebimento: params[:observacao_recebimento].presence || "Transferência recusada.",
          saldo_origem_depois: origem_depois
        )
      end

      redirect_to estoque_local_path(@movimentacao.destino_local),
        notice: "Transferência recusada. O saldo voltou para o estoque de origem."
    rescue ArgumentError, ActiveRecord::RecordInvalid => e
      redirect_to estoque_recebimento_path(@movimentacao),
        alert: e.message
    end

    private

    def set_local
      @local = Local.find(params[:local_id])
    end

    def set_movimentacao
      @movimentacao = Movimentacao.find(params[:id])
    end

    def extrair_qr_token(valor)
      return nil if valor.blank?

      texto = valor.to_s.strip

      if texto.include?("/estoque/scanner/produto/")
        texto.split("/estoque/scanner/produto/").last.split(/[?#]/).first
      else
        texto
      end
    end
  end
end