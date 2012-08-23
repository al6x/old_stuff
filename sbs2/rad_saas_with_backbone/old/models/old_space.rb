#
# Roles and Permissions
#
attr_writer :custom_viewers
def custom_viewers; @custom_viewers ||= [] end
available_as_string :custom_viewers, :column
assign :custom_viewers_as_string, String, true

attr_writer :custom_roles
def custom_roles; @custom_roles ||= [] end
available_as_string :custom_roles, :column
assign :custom_roles_as_string, String, true

attr_writer :custom_permissions
def custom_permissions; @custom_permissions ||= {} end
available_as_string :custom_permissions, :yaml
assign :custom_permissions_as_string, String, true

# allow choose from predefined set of common access types
attr_accessor :access_type
assign :access_type, String, true
def access_type; @access_type ||= 'private' end
before_save :access_type
validates_presence_of :access_type

# TODO3 move to IoC config
COMMON_PERMISSIONS = {
  'anonymous' => {
    'create'         => ['user'],
    'create_comment' => ['user'],
    'destroy'        => ['manager'],
    'update_access'  => ['manager']
  },
  'public_with_anonymous_comments' => {
    'create'         => ['registered'],
    'create_comment' => ['user'],
    'destroy'        => ['manager'],
    'update_access'  => ['manager']
  },
  'public' => {
    'create'        => ['registered'],
    'destroy'       => ['manager'],
    'update_access' => ['manager'],
  },
  'member' => {},
  'private_with_anonymous_comments' => {
    'create_comment' => ['user']
  },
  'private' => {}
}
COMMON_VIEWERS = {
  'anonymous'                       => ['user'],
  'public_with_anonymous_comments'  => ['user'],
  'public'                          => ['user'],
  'member'                          => ['member'],
  'private'                         => [],
  'private_with_anonymous_comments' => []
}

ACCESS_TYPES = %w(anonymous public_with_anonymous_comments public member private private_with_anonymous_comments custom)
validates_inclusion_of :access_type, in: ACCESS_TYPES

def default_viewers
  (access_type == 'custom') ? custom_viewers : COMMON_VIEWERS[access_type]
end

def permissions
  (access_type == 'custom') ? custom_permissions : COMMON_PERMISSIONS[access_type]
end
def permissions= permissions
  self.access_type = 'custom'
  self.custom_permissions = permissions
end


#
# Links
#
def self.accessible_as_string_menu attr_name
  define_method :"#{attr_name}_as_string" do
    self.send(attr_name).to_a.collect{|name, url| "#{name}: #{url}"}.join("\n")
  end

  define_method :"#{attr_name}_as_string=" do |str|
    self.send :"#{attr_name}=", []
    lines = str.split("\n")
    lines.each do |line|
      if match = line.html_escape.match(/^(.+?):(.+)$/)
        name, url = match[1].strip, match[2].strip
        self.send(attr_name) << [name, url] unless name.blank? or url.blank?
      end
    end
  end
end

attr_writer :menu
def menu; @menu ||= [] end
accessible_as_string_menu :menu
assign :menu_as_string, String, true


#
# Tags
#
attr_writer :space_tags
def space_tags; @space_tags ||= [] end
available_as_string :space_tags, :line
assign :space_tags_as_string, String, true

attr_writer :space_home_tag
def space_home_tag; @space_home_tag ||= '' end
assign :space_home_tag, String, true

attr_writer :additional_menu
def additional_menu; @additional_menu ||= [] end
MAX_TAGS_PERFORMANCE_LIMIT = 20

def build_additional_menu
  # return unless space_tags_changed? or space_home_tag_changed? or default_url_changed?

  # retrieving spaces
  spaces = account.spaces({space_tags: {_exists: true}}, {limit: MAX_TAGS_PERFORMANCE_LIMIT}).all

  # calculating additional_menu
  links = []
  spaces.each do |space|
    links << [space.space_home_tag, space.default_url] if space.space_home_tag.present?
  end
  links.sort!{|a, b| a.first <=> b.first}

  spaces.each do |space|
    additional_menu = []
    links.each do |name, url|
      url = '/' if space.space_tags.include? name
      additional_menu << [name, url]
    end
    space.additional_menu = additional_menu

    # updating spaces
    space.class.collection.update({_id: space._id}, _set: {additional_menu: additional_menu})
  end
end
attr_accessor :_update_additional_menu
before_save do |m|
  m._update_additional_menu = !m.original or (
    m.space_tags     != m.original.space_tags or
    m.space_home_tag != m.original.space_home_tag or
    m.default_url    != m.original.default_url
  )
end
after_save{|m| m.build_additional_menu if m._update_additional_menu}

attr_accessor :order_processing_email

attr_writer :currency
def currency; @currency ||= '$' end

assign do
  bottom_text_as_string String, true
  order_processing_email String, true
  currency String, true
  theme String, true
end