class AsyncBlock
	include OpenWFE::LocalParticipant
	def consume workitem
		begin
			result = self.send_msg workitem
			pname = workitem.participant_name
			service.send_msg workitem.fei.to_s, pname, result	
			
			workitem.set_result(result) if result and result != workitem
			
# ! DOES WE NEED TO REPLY HERE?			
#			reply_to_engine(workitem) if workitem.kind_of?(OpenWFE::InFlowWorkItem)
			# else it's a cancel item
		rescue Exception => e
			puts e
			raise e
		end
	end
end

class AsyncService
	attr_accessor :wf_engine
	
	def receive_msg sfei, participant_name, result_msg
		begin
			fei = OpenWFE::FlowExpressionId.from_s(sfei)
			
			workitem = wf_engine.process_status(fei.wfid).expressions.find { |fexp|
				fexp.fei = fei
			}.applied_workitem
			
			participant = wf_engine.get_participant_map.lookup_participant(participant_name)
			result = participant.receive_msg workitem, result_msg
			
			workitem.set_result(result) if result and result != workitem
			participant.reply_to_engine(workitem) if workitem.kind_of?(OpenWFE::InFlowWorkItem)
		rescue Exception => e
			puts e
			raise e
		end
	end
end