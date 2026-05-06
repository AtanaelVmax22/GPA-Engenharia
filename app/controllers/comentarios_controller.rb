class ComentariosController < ApplicationController
  def create
    @post = PostTecnico.find(params[:post_tecnico_id])
    @comentario = @post.comentarios.new(conteudo: params[:comentario][:conteudo])
    @comentario.user = current_user
    @comentario.save
    redirect_to @post
  end

  def destroy
    @comentario = Comentario.find(params[:id])
    @post = @comentario.post_tecnico
    @comentario.destroy if @comentario.user == current_user || current_user.admin?
    redirect_to @post
  end
end
