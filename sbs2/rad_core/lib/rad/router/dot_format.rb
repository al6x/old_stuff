# Parses format defined in path i.e. `/some_path.json` will be parsed as `/some_path` and `json`
class Rad::Router::DotFormat
  def encode! path, params
    if (format = params.delete(:format)).present?
      ["#{path}.#{format}", params]
    else
      [path, params]
    end
  end

  def decode! path, params
    path, format = parse_format path
    if format
      params[:format] = format
      [path, params]
    else
      [path, params]
    end
  end

  def parse_format path
    if path =~ /\.[^\.]+$/
      path.rsplit '.', 2
    else
      [path, nil]
    end
  end
end