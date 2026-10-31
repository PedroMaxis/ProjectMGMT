class RoadmapController < ApplicationController
  def show
    @products = Product.visible.includes(:releases, projects: :lead).order(:name)
    @loose = Project.open.where(product_id: nil).includes(:lead).order(:start_date)
    datas = Project.open.flat_map { |p| [ p.start_date, p.due_date ] } + Release.where.not(target_date: nil).pluck(:target_date)
    datas << Date.current
    @range = (datas.min.beginning_of_month..datas.max.end_of_month)
  end
end
