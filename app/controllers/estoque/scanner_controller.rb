module Estoque
  class ScannerController < BaseController
    def index
    end

    def produto
      produto = Produto.find_by!(qr_token: params[:qr_token])
      redirect_to estoque_produto_path(produto), notice: "Produto identificado pelo QR Code."
    end

    def local
      local = Local.find_by!(qr_token: params[:qr_token])
      redirect_to estoque_local_path(local), notice: "Estoque identificado pelo QR Code."
    end
  end
end