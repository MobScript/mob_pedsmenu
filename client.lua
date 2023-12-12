-- Key bindings
local Keys = {
    -- Add a comment explaining the purpose of key bindings
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}

-- Initialize ESX and player data
ESX = nil
local PlayerData = {}

-- Table containing allowed peds for each player
local allowedPeds = {
    -- Add comments explaining the structure of the allowedPeds table
    ["char1:iddemo"] = {"nameped_1", "nameped_2", "nameped_3"},  -- User 1
    ["char1:iddemo"] = {"nameped_1"}  -- User 2
}

Citizen.CreateThread(function()
    -- Wait for ESX to be initialized
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

-- Event to open the ped menu
RegisterNetEvent("mob_pedsmenu:pedmeny")
AddEventHandler("mob_pedsmenu:pedmeny", function()
    -- Call the function to open the gender selection menu
    OpenGenderMenu()
end)

-- Function to open the gender selection menu
OpenGenderMenu = function()
    -- Get the current player's identifier
    local currentPlayerIdentifier = ESX.GetPlayerData().identifier

    -- Check if the player has a list of allowed peds
    local playerAllowedPeds = allowedPeds[currentPlayerIdentifier]

    if playerAllowedPeds then
        -- Create elements for the gender selection menu
        local menuElements = {
            {
                ["label"] = "My Peds",
                ["action"] = "choose_gender",
                ["value"] = nil
            },
            {
                ["label"] = "Male Peds",
                ["action"] = "choose_gender",
                ["value"] = "male"
            },
            {
                ["label"] = "Female Peds",
                ["action"] = "choose_gender",
                ["value"] = "female"
            }
        }

        -- Open the ESX default menu with gender options
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "gender_menu", {
            ["title"] = "Gender",
            ["align"] = "center",
            ["elements"] = menuElements
        }, function(menuData, menuHandle)
            local action = menuData["current"]["action"]

            if action == "choose_gender" then
                local chosenGender = menuData["current"]["value"]

                if chosenGender then
                    -- Call the function to open the ped selection menu
                    OpenPedMenu(chosenGender, playerAllowedPeds)
                end
            end
        end, function(menuData, menuHandle)
            menuHandle.close()
        end)
    else
        -- Display a notification if the player has no allowed peds
        exports.pNotify:SendNotification({text = 'You don\'t have allowed peds.', type = "error", timeout = 200, layout = "bottomCenter", queue = "center"})
    end
end

-- Function to open the ped selection menu
OpenPedMenu = function(gender, allowedPedList)
    -- Create elements for the ped selection menu
    local menuElements = {
        {
            ["label"] = "Choose a ped to become",
            ["action"] = "choose_ped"
        }
    }

    -- Add each allowed ped to the menu elements
    for _, pedModel in ipairs(allowedPedList) do
        table.insert(menuElements, {
            ["label"] = pedModel,
            ["action"] = "choose_ped",
            ["value"] = pedModel
        })
    end

    -- Open the ESX default menu with ped options
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "ped_menu", {
        ["title"] = "Peds",
        ["align"] = "center",
        ["elements"] = menuElements
    }, function(menuData, menuHandle)
        local action = menuData["current"]["action"]

        if action == "choose_ped" then
            local pedModelChosen = menuData["current"]["value"]

            if IsModelInCdimage(pedModelChosen) then
                while not HasModelLoaded(pedModelChosen) do
                    Citizen.Wait(5)
                    RequestModel(pedModelChosen)
                end

                -- Set the player model to the chosen ped
                SetPlayerModel(PlayerId(), pedModelChosen)

                -- Determine the player's gender
                local isMale = gender == "male"

                -- Change the walking style based on gender
                if isMale then
                    SetPedMovementClipset(PlayerPedId(), "move_m@generic", 1.0)
                else
                    SetPedMovementClipset(PlayerPedId(), "move_f@generic", 1.0)
                end

                menuHandle.close()
            else
                -- Display a notification for an invalid ped
                exports.pNotify:SendNotification({text = 'Invalid PED', type = "error", timeout = 200, layout = "bottomCenter", queue = "center"})
            end
        end
    end, function(menuData, menuHandle)
        menuHandle.close()
    end)
end

-- List of allowed player identifiers
local allowedIdentifiers = {
    "char1:iddemo",  -- User 1
    "char1:iddemo"   -- User 2
}

-- Main thread to check for key press and open the ped menu
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        local currentPlayerIdentifier = ESX.GetPlayerData().identifier

        if IsControlJustReleased(0, Keys['M']) then
            for _, allowedIdentifier in ipairs(allowedIdentifiers) do
                if currentPlayerIdentifier == allowedIdentifier then
                    Wait(500)
                    -- Trigger the event to open the ped menu
                    TriggerEvent("mob_pedsmenu:pedmeny")
                    break
                end
            end
        end
    end
end)
