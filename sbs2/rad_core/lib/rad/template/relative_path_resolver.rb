# Sometimes relative path may have different meanings, for example in
# controllers relative path may also include all relative paths of controller superclasses.
#
# This resolver by relative path mean relative path.
class Rad::Template::RelativePathResolver
  def find_relative_template tname, prefixes, format, exact_format, current_dir
    raise "You can't use relative template path '#{tname}' without :current_dir!" unless current_dir
    prefixes = prefixes || rad.template.prefixes
    rad.template.find_file("/#{tname}", prefixes, format, exact_format, [current_dir])
  end
  cache_method_with_params_in_production :find_relative_template
end