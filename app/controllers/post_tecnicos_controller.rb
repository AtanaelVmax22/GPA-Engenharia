class PostTecnicosController < ApplicationController
  before_action :set_post, only: [:show, :destroy]

  def index
    @posts = PostTecnico.includes(:user, :condominio, :comentarios, :curtidas, midias_attachments: :blob).recentes
    @posts = @posts.where("titulo ILIKE ? OR conteudo ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
    @pagy, @posts = pagy(@posts, limit: 10)
  end

  def show
    @comentario = Comentario.new
  end

  def new
    @post = PostTecnico.new
    @condominios = Condominio.ativo.order(:nome)
  end

  def create
    @post = current_user.post_tecnicos.new(post_params)
    if @post.save
      redirect_to post_tecnicos_path, notice: "Post publicado!"
    else
      @condominios = Condominio.ativo.order(:nome)
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy if @post.user == current_user || current_user.admin?
    redirect_to post_tecnicos_path
  end

  private

  def set_post
    @post = PostTecnico.find(params[:id])
  end

  def post_params
    p = params.require(:post_tecnico).permit(:titulo, :conteudo, :condominio_id, midias: [])
    p[:condominio_id] = nil if p[:condominio_id].blank?
    p[:midias]&.reject!(&:blank?)
    p
  end
end
