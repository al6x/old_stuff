class Folder < Item  
  contains :files
  add_order_support_for :files
end