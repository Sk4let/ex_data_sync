GlobalState["totalPlayers"] = GetNumPlayerIndices()

if Config.jobList then
    for _, name in pairs(Config.jobList) do
        GlobalState[("dutyCount.%s"):format(name)] = 0
    end
end

if Config.events.setJob then
    AddEventHandler(Config.events.setJob, function(playerId, job, lastJob)
        if job.grade ~= lastJob.grade then
            Player(playerId).state:set(
                "job",
                { name = job.name or '', grade = job.grade or 0, label = job.label or '' },
                true
            )
            if GlobalState[("dutyCount.%s"):format(lastJob.name)] > 0 then
                GlobalState[("dutyCount.%s"):format(lastJob.name)] -= 1
            end
            GlobalState[("dutyCount.%s"):format(job.name)] += 1
        end
    end)
end

if Config.events.playerDropped then
    AddEventHandler(Config.events.playerDropped, function(reason)
        GlobalState["totalPlayers"] = GetNumPlayerIndices()
    end)
end

if Config.events.playerLoaded then
    AddEventHandler(Config.events.playerLoaded, function(playerId, player)
        Player(playerId).state:set(
            "job",
            { name = player.job.name or '', grade = player.job.grade or 0, label = player.job.label or '' },
            true
        )
        GlobalState["totalPlayers"] = GetNumPlayerIndices()
    end)
end

RegisterCommand('tg', function(a, b)
    GlobalState["totalPlayers"] = math.random(1, 10)
end)
