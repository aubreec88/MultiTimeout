--!optimize 2
--!native

type TimeoutValue = {
	TargetThread:thread,
	TimeoutAfter:number,
	ThreadType:number?,
	ShouldYield:boolean?,
}

-- W and interesting way of typing because im too lazy to do it in the normal way <butter>
type Function = typeof(function() end)

local Main = {}

--[[
	Values:
		TargetThread:thread
		TimeoutAfter:number
		ThreadType:number?
		ShouldYield:boolean?

	Thread type explanation:
		0 = For threads created with the task library.
		1 = For threads created with the coroutine library.
		
	<butter>
]]
function Main.Timeout(Values:TimeoutValue)
	assert(Values.TargetThread, "No target thread was given.")
	assert(Values.TimeoutAfter, "No timeout value was given.")
	
	local targetThread:thread = Values.TargetThread
	local timeoutValue:number = Values.TimeoutAfter
	local threadType:number = (Values.ThreadType or 0)
	local shouldYield:boolean = (Values.ShouldYield or false)
	
	local targetCancelFunction:Function = (threadType == 0 and task.cancel or coroutine.close)
	
	if shouldYield then
		task.wait(timeoutValue)
		
		if coroutine.status(targetThread) == "dead" then
			return
		end
		
		targetCancelFunction(targetThread)
		
		return
	end
	
	task.delay(timeoutValue, function()
		if coroutine.status(targetThread) == "dead" then
			return
		end

		targetCancelFunction(targetThread)
	end)
end

return Main
