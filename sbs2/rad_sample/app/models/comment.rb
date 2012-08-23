class Comment < Node      
  field :text, type: String
  validates_presence_of :text
  
  belongs_to :node, class_name: 'Models::Node', counter_cache: true
  
  index :node_id
end