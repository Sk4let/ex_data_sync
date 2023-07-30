-- Helper function to update duty count in GlobalState
local function updateDutyCount(jobName, increment)
    if GlobalState[("dutyCount.%s"):format(jobName)] then
        GlobalState[("dutyCount.%s"):format(jobName)] = GlobalState[("dutyCount.%s"):format(jobName)] + increment
    end
end

-- Helper function to set player's job state and update duty count
local function setPlayerJobState(playerId, job)
    Player(playerId).state:set(
        "job",
        {
            name = job.name or '',
            grade = job.grade or 0,
            label = job.label or ''
        },
        true
    )
end

-- Initialize totalPlayers and dutyCount for each job
GlobalState["totalPlayers"] = GetNumPlayerIndices()

if Config.jobList then
    for _, name in pairs(Config.jobList) do
        GlobalState[("dutyCount.%s"):format(name)] = 0
    end
end

-- Event handler for when a player's job is set
if Config.events.setJob then
    AddEventHandler(Config.events.setJob, function(playerId, job, lastJob)
        setPlayerJobState(playerId, job)
        updateDutyCount(lastJob.name, -1)
        updateDutyCount(job.name, 1)
    end)
end

-- Event handler for when a player disconnects
if Config.events.playerDropped then
    AddEventHandler(Config.events.playerDropped, function(reason)
        GlobalState["totalPlayers"] = GetNumPlayerIndices()
    end)
end

-- Event handler for when a player's data is loaded
if Config.events.playerLoaded then
    AddEventHandler(Config.events.playerLoaded, function(playerId, player)
        setPlayerJobState(playerId, player.job)
        GlobalState["totalPlayers"] = GetNumPlayerIndices()
    end)
end