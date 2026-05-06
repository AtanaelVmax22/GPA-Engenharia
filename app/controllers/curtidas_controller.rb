class CurtidasController < ApplicationController
  def create
    @post = PostTecnico.find(params[:post_tecnico_id])
    @post.curtidas.find_or_create_by(user: current_user)
    redirect_back fallback_location: @post
  end

  def destroy
    @post = PostTecnico.find(params[:post_tecnico_id])
    @post.curtidas.find_by(user: current_user)&.destroy
    redirect_back fallback_location: @post
  end
end
