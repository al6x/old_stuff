class Post < Node
  field :name, type: String
  validates_presence_of :name
    
  field :text, type: String
  validates_presence_of :text
end