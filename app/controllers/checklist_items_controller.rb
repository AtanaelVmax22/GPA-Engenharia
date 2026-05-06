class ChecklistItemsController < ApplicationController
  def create
    @checklist = Checklist.find(params[:checklist_id])
    @item = @checklist.checklist_items.create(item_params)
    redirect_to @checklist
  end

  def update
    @item = ChecklistItem.find(params[:id])
    @item.update(concluido: params[:checklist_item][:concluido])
    redirect_to @item.checklist
  end

  def destroy
    @item = ChecklistItem.find(params[:id])
    checklist = @item.checklist
    @item.destroy
    redirect_to checklist
  end

  private

  def item_params
    params.require(:checklist_item).permit(:descricao, :ordem, :concluido)
  end
end
