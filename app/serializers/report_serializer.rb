class ReportSerializer < ActiveModel::Serializer
  attributes :id, :title, :journal_entry_id, :child_id, :parent_id, :anger, :disgust, :fear, :joy, :sadness, :surprise, :date, :created_at

  def date 
    self.object.created_at.strftime("%b %d, %Y")
  end 
end


