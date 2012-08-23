require "#{File.dirname __FILE__}/../spaces_api"

class SpacesLoader < ETL::Loader
  def create_page obj
    if Page.exists? obj.slug
      page = Page.find obj.slug
      page.destroy
    end    

    page = Page.new(:name => obj.title, :tags => obj.tags, :slug => obj.slug, :text => obj.details)       
    page.save.should! :be_true

    # icon
    extractor.read_image(obj.page_url, obj.icon){|f| page.icon = f}
    # fname = "#{page_directory(obj.page_link)}/#{obj.icon}"
    # File.open(fname){|f| page.icon = f}

    page.set_visibility :user
    page
  end

  def create_note obj, page
    note = Note.new(:text => obj.text)
    note.save.should! :be_true

    page.add note

    note
  end

  def create_folder obj, page
    return nil if obj.images.empty?

    folder = Folder.new()
    folder.save.should! :be_true

    page.add folder

    folder
  end
  
  def create_images obj, folder
    obj.images.each do |img_name|
      new_name = obj.image_base + img_name
      
      file = IFile.new :slug => transformer.image_slug(obj.image_base, img_name)
      file.save

      # image      
      fname = extractor.image_file_name obj.page_url, img_name
      new_fname = "#{Dir.tmpdir}/#{new_name}"      
      File.delete new_fname if File.exists? new_fname
      begin
        FileUtils.cp fname, new_fname
        File.open(new_fname){|f| file.file = f}
      ensure
        File.delete new_fname
      end

      folder.add file
    end
  end  
end

SpacesResource.site = "http://tech4y.saas4b.com/"
SpacesResource.user = 'admin'
SpacesResource.password = 'admin'

# SpacesResource.site = "http://localhost:3000/"
# SpacesResource.user = 'admin'
# SpacesResource.password = 'admin'

# puts "Enter Password for #{SpacesResource.site}"
# password = gets


$tec4y.loader = SpacesLoader.new $tec4y.base, $tec4y.extractor, $tec4y.transformer do |l|
  l.each_object do |obj|
    page = l.create_page obj
    note = l.create_note obj, page
    folder = l.create_folder obj, page

    images = l.create_images obj, folder  
  end
end