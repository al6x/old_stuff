class Node
  include Mongoid::Document  
  store_in 'nodes'
  
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated
  
  def to_param; id.to_s end  
  def self.by_param param
    self.by_id(param)
  end
  def self.by_param! param
    by_param(param) || raise(Mongoid::Errors::DocumentNotFound.new(self, param))
  end
  
  has_many :comments, order: 'created_at', dependent: :destroy, foreign_key: :node_id, class_name: 'Models::Comment'
  field :comments_count, type: Integer, default: 0
  
  index :_type
  index :created_at
  index :updated_at
end