class Task < Item      
  validates_presence_of :name
  
  markup_key :text
  
  key :state, String, protected: true
  
  state_machine :state, initial: 'active' do
    on :activate do
      transition all => :active
    end
  
    on :finish do
      transition all => :finished
    end    
  end
  
  # TODO2 fix it
  # searchable do
  #   text :text, using: :text_as_text
  # end
end