%w{GeneralSpec FiltersSpec UsabilitySpec SeleniumServiceSpec}.each do |name|
	require File.dirname(__FILE__) + "/" + name
end