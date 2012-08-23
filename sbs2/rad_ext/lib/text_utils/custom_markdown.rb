class TextUtils::CustomMarkdown < TextUtils::Processor
  def call data, env
    if env[:format] == :markdown
      hide_html_tags data do |data|
        image_box data do |data|
          call_next data, env
        end
      end
    else
      call_next data, env
    end
  end

  protected
    def hide_html_tags data, &block
      snippets, counter = {}, 0
      data = data.gsub /<.+?>/ do
        key = "HTMLSNIPPET#{counter}"; counter += 1
        snippets[key] = $&
        key
      end

      data = block.call data

      data = data.gsub /HTMLSNIPPET\d+/ do
        snippets[$&]
      end
      data
    end

    # !![img] => [![img_thumb]][img]
    def image_box data, &block
      img_urls = {}
      data = data.gsub(/!!\[(.+?)\]/) do
        img_key = $1 || ''
        if url = data.scan(/\[#{img_key}\]:\s*([^\s]+)$/).first.try(:first)
          unless url =~ /\.[^\.]+\.[^\.]+$/ # image.png
            thumb_img_key = "#{img_key}_thumb"

            # Building url with thumb (foo.png => foo.thumb.png)
            img_urls[thumb_img_key] = url.sub(/\.([^\.]+)$/){".thumb.#{$1}"}

            "[![][#{thumb_img_key}]][#{img_key}]"
          else # image.(icon|thumb|...).png
            img_key_full = "#{img_key}_full"

            # Building url with thumb (foo.png => foo.thumb.png)
            img_urls[img_key_full] = url.sub(/\.([^\.]+)\.([^\.]+)$/){".#{$2}"}

            "[![][#{img_key}]][#{img_key_full}]"
          end
        else
          $& || ''
        end
      end

      unless img_urls.blank?
        data << "\n"
        data << img_urls.to_a.collect{|k, v| "[#{k}]: #{v}"}.join("\n")
      end

      block.call data
    end
end