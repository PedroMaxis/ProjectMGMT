class CommentsController < ApplicationController
  before_action :require_editor!
  before_action :set_issue

  def create
    comment = @issue.comments.new(params.require(:comment).permit(:body))
    comment.user = current_user
    if comment.save
      redirect_to issue_path(@issue), notice: "Comentário publicado."
    else
      redirect_to issue_path(@issue), alert: comment.errors.full_messages.to_sentence
    end
  end

  def destroy
    comment = @issue.comments.find(params[:id])
    if comment.user == current_user || current_user.admin?
      comment.destroy
      redirect_to issue_path(@issue), notice: "Comentário excluído."
    else
      redirect_to issue_path(@issue), alert: "Você só pode excluir os seus comentários."
    end
  end

  private

  def set_issue = @issue = Issue.find_by_key!(params[:issue_key])
end
