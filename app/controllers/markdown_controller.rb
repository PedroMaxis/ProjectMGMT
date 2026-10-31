# Pré-visualização do Markdown enquanto se escreve (usada no editor de páginas e nos comentários).
class MarkdownController < ApplicationController
  def create
    render html: helpers.render_markdown(params[:text].to_s.first(20_000)), layout: false
  end
end
