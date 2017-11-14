require 'initenv'
require 'cunn'
require'cutorch'
require 'nn'
plt = require 'gnuplot'
local agent_type = "DQN3_0_1__"
local a_r_table = {}
function plotAgent(agent_name,title,limit,object_net_info)
	local agent = torch.load(agent_name..".t7")
	--limit = math.min(#agent.reward_history,limit or #agent.reward_history)
    print (#agent.reward_history)
	local reward = torch.CudaTensor(limit):zero()
	local loss = torch.CudaTensor(limit):zero()
	local acc = torch.CudaTensor(limit):zero()

	for i=1,math.min(#agent.reward_history,limit or #agent.reward_history) do
		reward[i] = agent.reward_history[i]
        if object_net_info then	
	        local temp = agent.obj_loss_history[i]
		    loss[i] = temp[1]
		    acc[i] = temp[2]
        end
	end
    if not object_net_info then
        loss=nil
        acc=nil
    end
	
	table.insert(a_r_table,{title or agent_name, reward:narrow(1,1,limit)})
    --plot seperate graph for object network
    if object_net_info then	
        plt.figure()
	    plt.title(title or agent_name .. "Object Network Preformance")
	    plt.plot({'Binary Cross Entropy loss', loss:narrow(1,1,limit)},{'Accuracy',acc:narrow(1,1,limit)})
	    plt.movelegend('right','bottom')
	    plt.xlabel('Epochs, 10000 steps per epoch')
    end
    torch.save(agent_name.."_result_summary.t7",{reward = reward,loss = loss,acc = acc,limit =limit, title =title or agent_name})
end
function plotAgentFromSummary(agent_name)
    agent_summary = torch.load(agent_name.."_result_summary.t7")
    if agent_summary.loss then	
        plt.figure()
	    plt.title(agent_summary.title .. "Object Network Preformance")
	    plt.plot({'Binary Cross Entropy loss', agent_summary.loss:narrow(1,1,agent_summary.limit)},{'Accuracy',agent_summary.acc:narrow(1,1,agent_summary.limit)})
	    plt.movelegend('right','bottom')
	    plt.xlabel('Epochs, 10000 steps per epoch')
    end
	table.insert(a_r_table,{agent_summary.title, agent_summary.reward:narrow(1,1,agent_summary.limit)})
end

local limit=155

plt.figure(1)
--insert agents here

--plotAgent(agent_type.."FC_restrict_exploration_n_action", "Merged Agent", limit,true)
--plotAgent(agent_type.."FC_restrict_exploration", "Restricted exploration", limit,true)
plotAgent("DQN3_0_1__zork_FC_vanila_scenario_2_lr_1.9e7","vanila extended action space",limit,false)
--plotAgentFromSummary("_zork_FC_vanila_scenario_2")
plotAgent("DQN3_0_1__zork_FC_merged_scenario_2_lr_1.9e7","merged extended action space",limit,true)
--plotAgentFromSummary("_zork_FC_merged_scenario_2")
plotAgent("DQN3_0_1_zork_FC_greedy_scenario_2_lr1.7e7","greedy extended action space",limit,true)
--plot in main reward graph
plt.figure(1)
plt.title('DQN Agent Reward')
plt.xlabel('Epochs, 10000 steps per epoch')
plt.movelegend('right','bottom')
plt.plot(a_r_table)	
