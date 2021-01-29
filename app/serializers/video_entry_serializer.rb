class VideoEntrySerializer < ActiveModel::Serializer
  attributes :id, :title, :video, :video_report, :date 

  def date 
    self.object.created_at.strftime("%b %d, %Y")
  end
end
