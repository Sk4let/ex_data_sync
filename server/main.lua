-- Helper function to update duty count in GlobalState
local function updateDutyCount(jobName, increment)
    if GlobalState[("dutyCount.%s"):format(jobName)] then
        GlobalState[("dutyCount.%s"):format(jobName)] = math.max(0,
            GlobalState[("dutyCount.%s"):format(jobName)] + increment)
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
    updateDutyCount(job.name, 1)
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
    RegisterNetEvent(Config.events.setJob)
    AddEventHandler(Config.events.setJob, function(playerId, job, lastJob)
        setPlayerJobState(playerId, job)
        Wait(500)
        updateDutyCount(lastJob.name, -1)
    end)
end

-- Event handler for when a player disconnects
if Config.events.playerDropped then
    AddEventHandler(Config.events.playerDropped, function(reason)
        GlobalState["totalPlayers"] = GetNumPlayerIndices()
        local playerJobState = Player(source).state.job
        if playerJobState then
            for _, job in pairs(Config.jobList) do
                if playerJobState.name == job then
                    updateDutyCount(job, -1)
                    break
                end
            end
        end
    end)
end

-- Event handler for when a player's data is loaded
if Config.events.playerLoaded then
    RegisterNetEvent(Config.events.playerLoaded)
    AddEventHandler(Config.events.playerLoaded, function(playerId, player)
        setPlayerJobState(playerId, player.job)
        GlobalState["totalPlayers"] = GetNumPlayerIndices()
    end)
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if Config.framework == 'esx' then
        local ESX = exports.es_extended:getSharedObject()
        for _, playerId in pairs(GetPlayers()) do
            local xPlayer = ESX.GetPlayerFromId(playerId)
            for _, job in pairs(Config.jobList) do
                if xPlayer.job.name == job then
                    GlobalState[("dutyCount.%s"):format(job)] = GlobalState[("dutyCount.%s"):format(job)] + 1
                    break
                end
            end
        end
    end
end)
