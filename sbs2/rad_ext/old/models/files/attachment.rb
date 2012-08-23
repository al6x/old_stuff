class Models::Files::Attachment
  inherit Mongo::Model, Mongo::Model::FileModel

  mount_file :file, Models::Files::AttachmentFile
end