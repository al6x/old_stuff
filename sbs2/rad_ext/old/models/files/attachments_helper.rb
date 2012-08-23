module Models::Files::AttachmentsHelper
  class FileHelper
    attr_reader :object
    def initialize object
      @object = object
    end

    def file?
      object.is_a?(Hash) or object.is_a?(IO) or object.is_a?(Vfs::File)
    end

    def name
      if object.is_a?(Hash)
        object['filename'] || object[:filename]
      elsif object.is_a?(IO)
        File.basename(object.path)
      elsif object.is_a?(Vfs::File)
        object.name
      else
        object
      end
    end
  end

  def get_attachments association_name, field_name
    send(association_name).
      sort{|a, b| a.send(field_name).file.name <=> b.send(field_name).file.name}.
      collect{|o| {name: o.send(field_name).file.name, url: o.send(field_name).url}.to_openobject}
  end

  def set_attachments association_name, field_name, values, &block
    association = send(association_name)
    existing_names = association.collect{|o| o.send(field_name).file.name}.sort

    add = values.select do |o|
      h = FileHelper.new o
      h.file? and !existing_names.include?(h.name)
    end
    update = values.select do |o|
      h = FileHelper.new o
      h.file? and existing_names.include?(h.name)
    end
    remove = association.select do |model|
      values.none? do |o|
        h = FileHelper.new o
        model.send(field_name).name == h.name
      end
    end

    add.each do |file|
      model = block.call
      model._parent = self
      model.send "#{field_name}=", file
      association << model
    end
    update.each do |file|
      h = FileHelper.new file
      association.each do |model|
        if model.send(field_name).file.name == h.name
          model.send "#{field_name}=", file
          break
        end
      end
    end
    remove.each do |model|
      association.delete model
    end
  end

  module ClassMethods
    def mount_attachments association_name, field_name, &block
      define_method "#{association_name}_as_attachments" do
        get_attachments association_name, field_name
      end

      define_method "#{association_name}_as_attachments=" do |values|
        set_attachments association_name, field_name, values, &block
      end
    end
  end
end