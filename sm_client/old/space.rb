class Space < ActiveRecord::Base
  establish_connection_to_service_mix
  
  belongs_to :account
  has_many :roles
  
  validates_presence_of :name, :account
  validates_format_of :name, :with => STRONG_NAME
  
  def self.current= account
    Thread.current['current_space'] = account
  end

  def self.current
    Thread.current['current_space'].should_not! :be_nil
  end
  
  def self.current?
    Thread.current['current_space'] != nil
  end
end
# == Schema Information
#
# Table name: spaces
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  account_id :integer(4)
#  created_at :datetime
#  updated_at :datetime
#