class DashboardController < ApplicationController
  def index
    @total_condominios = Condominio.ativo.count
    @total_equipamentos = Equipamento.count
    @ordens_mes = HistoricoTecnico.where(created_at: 30.days.ago..).count
    @pendencias = HistoricoTecnico.pendente.count
    @historicos_recentes = HistoricoTecnico.includes(:condominio, :user).recentes.limit(5)
    @posts_recentes = PostTecnico.includes(:user).recentes.limit(5)
    @condominios_atencao = Condominio.ativo.joins(:historico_tecnicos)
                                     .where(historico_tecnicos: { status: :pendente }).distinct.limit(3)

    registros = HistoricoTecnico.where(created_at: 6.months.ago..).pluck(:created_at)
    @ordens_por_mes = 6.downto(1).each_with_object({}) do |n, h|
      ref = n.months.ago.beginning_of_month
      h[ref] = registros.count { |d| d.beginning_of_month == ref }
    end
  end
end
