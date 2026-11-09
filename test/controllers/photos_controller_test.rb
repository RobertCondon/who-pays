require "test_helper"

class PhotosControllerTest < ActionDispatch::IntegrationTest
  setup { @recipt = ReciptParser.import!(file_fixture("receipt.txt").read) }

  test "upload, show and remove a receipt photo" do
    post recipt_photos_path(@recipt), params: { photos: [ fixture_file_upload("receipt.png", "image/png") ] }
    assert_redirected_to recipt_path(@recipt)
    assert_equal 1, @recipt.photos.count

    get recipt_path(@recipt)
    assert_select ".photo img[alt='receipt.png']"

    delete recipt_photo_path(@recipt, @recipt.photos.first)
    assert_equal 0, @recipt.reload.photos.count
  end

  test "rejects files that are not images or PDFs" do
    post recipt_photos_path(@recipt), params: { photos: [ fixture_file_upload("receipt.txt", "text/plain") ] }
    assert_equal 0, @recipt.photos.count
    assert_match "Only images or PDFs", flash[:alert]
  end
end
