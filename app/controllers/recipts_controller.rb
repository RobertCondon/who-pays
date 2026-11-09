class ReciptsController < ApplicationController
  def index
    @recipts = Recipt.includes(:recipt_items).order(opened_at: :desc, id: :desc)
  end

  def show
    @recipt = Recipt.includes(recipt_items: :paid_by).with_attached_photos.find(params[:id])
    @people = Person.order(:name)
  end

  def new
  end

  # Paste the raw POS text and it gets parsed into items.
  def create
    recipt = ReciptParser.import!(params.require(:text), venue: params[:venue].presence)
    if recipt.recipt_items.empty?
      recipt.destroy
      redirect_to new_recipt_path, alert: "Couldn't find any items in that text."
    else
      redirect_to recipt, notice: "Imported #{recipt.recipt_items.size} items."
    end
  end

  def destroy
    Recipt.find(params[:id]).destroy
    redirect_to recipts_path, notice: "Receipt deleted.", status: :see_other
  end
end
