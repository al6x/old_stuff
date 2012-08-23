class Models::Item
  def attachments
    @attachments ||= []
  end
  mount_attachments(:attachments, :file){Models::Files::Attachment.new}

  assign :attachments_as_attachments, true

  def attachments_as_images
    # TODO3 remove sorting, use order defined in database.
    _cache[:attachments_as_images] ||= attachments.
      sort{|a, b| a.file.name <=> b.file.name}.
      collect{|o| {name: o.file.name, url: o.file.url, thumb_url: o.file.thumb.url, icon_url: o.file.icon.url}.to_openobject}
  end
end