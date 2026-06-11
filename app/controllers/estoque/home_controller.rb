module Estoque
  class HomeController < BaseController
    def index
      @produtos_count = Produto.count
      @locais_count = Local.count
      @saldos_count = Saldo.where("quantidade > 0").count
      @ultimas_movimentacoes = Movimentacao.includes(:produto, :origem_local, :destino_local, :user).order(created_at: :desc).limit(8)
    end
  end
end