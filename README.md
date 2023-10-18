# ex data sync

To cache duty count , total players , player's job for FiveM using StateBag, `require OneSync`

## Features

- Standalone can be used without a framework.
- Use `GlobalState` to synchronize for every client.
- There's no need to use `TriggerClientEvent` to send data anymore.
- Use `AddStatebag` to synchronize when updating.

## Usage (Client)

```lua

    -- Example: Updating duty count, total players, and job label on the scoreboard
    Config.department = {
        ['police'] = 'ตำรวจ',
        ['ambulance'] = 'หมอ',
        ['mechanic'] = 'ช่าง',
        ['council'] = 'สภา',
    }

    local function getCurrentData()
        Wait(3000)
        local department = {}
        for name, label in pairs(Config.department) do
            table.insert(department, {
                name = name,
                label = label,
                total = GlobalState[("dutyCount.%s"):format(name)] or 0
            })
        end

        return {
            department = department,
            totalPlayers = GlobalState["totalPlayers"] or 0,
            jobLabel = (LocalPlayer.state.job and LocalPlayer.state.job.label) or 'unemployed',
        }
    end

    for name, _ in pairs(Config.department) do
	AddStateBagChangeHandler(('dutyCount.%s'):format(name), nil, function(_, _, _)
		SendNUIMessage({
			type = "updateInfo",
			payload = {
				totalPlayers = GlobalState["totalPlayers"] or 0,
                jobLabel = (LocalPlayer.state.job and LocalPlayer.state.job.label) or 'unemployed'
			}
		})
	end)


    -- Example: Updating player job data when the `setJob` event is used
    local function setStateBagHandler(playerId)
			AddStateBagChangeHandler("job", playerId, function(_, _, value, _, _)
				if value then
					SendNUIMessage({
						type = "updateInfo",
						payload = {
							data = getCurrentData(),
						}
					})
				end
			end)
		end

		if setStateBagHandler then
            local playerServerId = GetPlayerServerId(PlayerId()))
			setStateBagHandler(("player:%s"):format(playerServerId)
		end
end
```

## Usage (Server)

```lua

    -- Sample code to get a player's job from their server ID
    local playerState =  Player(playerId).state.job

    if playerState then
        print(playerState.job.name , playerState.job.label , playerState.job.grade)
    end

    -- Sample code to set a player's job
    -- If the 'Config.events.setJob' is enabled, setting a player's job will also automatically update the duty count.

    -- Sample code to update job state and global count without event-based system
    -- You have to manually update dutyCount by removing the latest job and increasing it (If without a "setJob" event)

    -- Helper function to update duty count in GlobalState
    local function updateDutyCount(jobName, increment)
        if GlobalState[("dutyCount.%s"):format(jobName)] then
            GlobalState[("dutyCount.%s"):format(jobName)] = math.max(0,
                GlobalState[("dutyCount.%s"):format(jobName)] + increment)
        end
    end

    Player(playerId).state:set("job",
            {
                name = job.name or '',
                grade = job.grade or 0,
                label = job.label or ''
            },
        true
    )
    updateDutyCount(--[[lastJob]]--, -1)
    updateDutyCount(--[[newJob]]--, -1)



    -- Sample code to get a duty count by job name
    local policeCount = GlobalState[("dutyCount.%s"):format('police')]

    -- Sample code to get the total number of online players
    local total = GlobalState["totalPlayers"]
end
```

## Statebags

| state | type | args %s | return | description |
|-------|------|---------|--------|-------------|
| `job` | table | - | {name, grade, label} or nil | Player's job array. |
| `totalPlayers` | integer | `-` | integer or 0 | Total online players. |
| `dutyCount.%s` | integer | `"default"` | `"police"`, `"ambulance"`, `"mechanic"`, `"any"` | integer or 0 | Total duty count. |

## Config

```lua
    framework = 'esx', -- Optionally update data when restarting the script.

    events = {
        setJob = "esx:setJob",
        playerLoaded = "esx:playerLoaded",
        playerDropped = "playerDropped"
    },

    jobList = {
        'police',
        'ambulance',
        'mechanic',
        'council',
    }
```
