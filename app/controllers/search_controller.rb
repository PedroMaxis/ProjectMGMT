class SearchController < ApplicationController
  def index
    @q = params[:q].to_s.strip
    @results = @q.length >= 2 ? buscar(@q, params[:limit].presence&.to_i || 8) : {}
    respond_to do |format|
      format.html
      format.json { render json: itens_json(@results) }
    end
  end

  private

  def buscar(q, limite)
    por_chave = Issue.find_by_key!(q) if q.match?(Issue::KEY_FORMAT) rescue nil
    tarefas = Issue.includes(:project).search(q).order(updated_at: :desc).limit(limite).to_a
    tarefas.unshift(por_chave) if por_chave && tarefas.exclude?(por_chave)
    {
      issues: tarefas.first(limite),
      projects: Project.matching(%w[name key], q).alphabetical.limit(limite),
      products: Product.matching("name", q).limit(limite),
      pages: Page.matching(%w[title body], q).limit(limite),
      users: User.matching(%w[name email], q).alphabetical.limit(limite)
    }
  end

  def itens_json(res)
    {
      issues: res.fetch(:issues, []).map { |i| { title: i.title, subtitle: "#{i.key} · #{I18n.t("enums.issue.status.#{i.status}")}", url: issue_path(i) } },
      projects: res.fetch(:projects, []).map { |p| { title: p.name, subtitle: "Projeto #{p.key}", url: project_path(p) } },
      products: res.fetch(:products, []).map { |p| { title: p.name, subtitle: "Produto", url: product_path(p) } },
      pages: res.fetch(:pages, []).map { |p| { title: p.title, subtitle: "Página em #{p.space.name}", url: page_path(p) } },
      users: res.fetch(:users, []).map { |u| { title: u.name, subtitle: u.job_title.to_s, url: user_path(u) } }
    }
  end
end
