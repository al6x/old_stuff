require "RubyExt/require"
require "ObjectModel/require"
ObjectModel::CONFIG[:cache] = "ObjectModel::Tools::InMemoryCache"

%w{
AspectSpec
BackReferencesSpec
BasicSpec
CascadeDeleteSpec
ComplexEventsSpec
ConcurrencySpec
ContainmentSpec
ErrorsSpec
EventsSpec
ExtendedSpec
IndexingSpec
SmokeSpec
StreamSpec
ValidationSpec
}.each{|file| require "#{File.dirname __FILE__}/#{file}"}
#ConcurrencySpec