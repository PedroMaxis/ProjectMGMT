class ReleasesController < ApplicationController
  before_action :require_editor!
  before_action :set_product

  def create
    release = @product.releases.new(release_params)
    if release.save
      redirect_to @product, notice: "Versão #{release.name} criada."
    else
      redirect_to @product, alert: release.errors.full_messages.to_sentence
    end
  end

  def update
    release = @product.releases.find(params[:id])
    attrs = release_params
    attrs[:released_on] ||= Date.current if attrs[:status] == "released" && release.released_on.blank?
    if release.update(attrs)
      redirect_to @product, notice: "Versão #{release.name} atualizada."
    else
      redirect_to @product, alert: release.errors.full_messages.to_sentence
    end
  end

  def destroy
    @product.releases.find(params[:id]).destroy
    redirect_to @product, notice: "Versão excluída."
  end

  private

  def set_product = @product = Product.find_by!(slug: params[:product_id])

  def release_params = params.require(:release).permit(:name, :status, :target_date, :released_on, :notes)
end
