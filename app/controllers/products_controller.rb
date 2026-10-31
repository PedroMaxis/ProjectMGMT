class ProductsController < ApplicationController
  before_action :require_editor!, except: %i[index show]
  before_action :set_product, only: %i[show edit update destroy]

  def index
    @products = Product.visible.includes(:owner, :projects).order(:name)
    @archived = Product.where(status: "archived").order(:name)
  end

  def show
    @releases = @product.releases.includes(:issues)
    @projects = @product.projects.includes(:lead).alphabetical
    @pages = @product.pages.roots.includes(:children)
    @release = @product.releases.new
  end

  def new
    @product = Product.new(owner: current_user)
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to @product, notice: "Produto criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: "Produto atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: "Produto excluído. Os projetos continuam existindo, sem produto."
  end

  private

  def set_product = @product = Product.find_by!(slug: params[:id])

  def product_params
    params.require(:product).permit(:name, :description, :vision, :status, :color, :owner_id)
  end
end
