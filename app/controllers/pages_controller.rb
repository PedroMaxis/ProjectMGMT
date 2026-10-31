class PagesController < ApplicationController
  before_action :require_editor!, except: :show
  before_action :set_page, only: %i[show edit update destroy]
  before_action :set_space_for_new, only: %i[new create]

  def show
    @space = @page.space
    @tree = arvore(@space)
  end

  def new
    @page = @space.pages.new(parent_id: params.dig(:page, :parent_id), icon: "📄")
  end

  def create
    @page = @space.pages.new(page_params)
    @page.author = current_user
    if @page.save
      redirect_to @page, notice: "Página criada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @space = @page.space
  end

  def update
    if @page.update(page_params)
      redirect_to @page, notice: "Página salva."
    else
      @space = @page.space
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    space = @page.space
    @page.destroy
    redirect_to space, notice: "Página excluída (e as subpáginas)."
  end

  private

  def set_page = @page = Page.find(params[:id])

  def set_space_for_new
    @space = params[:project_key] ? Project.find_by!(key: params[:project_key]) : Product.find_by!(slug: params[:product_id])
  end

  def page_params
    params.require(:page).permit(:title, :icon, :body, :parent_id, :position)
  end

  def arvore(space) = space.pages.roots.includes(children: :children)
end
