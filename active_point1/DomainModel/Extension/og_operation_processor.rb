::OGDomain::Operations::OperationProcessor
class ::OGDomain::Operations::OperationProcessor
	inherit DomainModel::Transactional
	
	transaction :join_begin, :execute
end