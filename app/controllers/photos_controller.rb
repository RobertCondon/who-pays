# Photos of the paper receipt, attached to a Recipt for auditing.
class PhotosController < ApplicationController
  ALLOWED_TYPES = %w[image/jpeg image/png image/webp image/heic image/heif image/gif application/pdf].freeze
  MAX_SIZE = 20.megabytes

  before_action :set_recipt

  def create
    files = Array(params[:photos]).compact_blank
    rejected = files.reject { |f| ALLOWED_TYPES.include?(f.content_type) && f.size <= MAX_SIZE }
    if files.empty? || rejected.any?
      return redirect_to @recipt, status: :see_other,
        alert: files.empty? ? "Choose a photo to upload." : "Only images or PDFs up to 20 MB: #{rejected.map(&:original_filename).to_sentence}"
    end

    @recipt.photos.attach(files)
    redirect_to @recipt, status: :see_other, notice: "Added #{helpers.pluralize(files.size, "photo")}."
  end

  def destroy
    @recipt.photos.find(params[:id]).purge
    redirect_to @recipt, status: :see_other, notice: "Photo removed."
  end

  private

  def set_recipt
    @recipt = Recipt.find(params[:recipt_id])
  end
end
