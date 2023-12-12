# GTA V Ped Selector Script

## Overview

This GTA V script allows players to change their character's gender and select from a list of predefined player models (peds). The script includes a user-friendly menu system and customization options.

## Features

- **Gender Selection:** Players can choose between male and female characters.
- **Ped Selection:** Access a list of allowed peds based on the player's identifier.
- **Walking Style Customization:** The script automatically adjusts the player's walking style based on the chosen gender.

## Key Bindings

- Press `M` to open the ped selector menu.

## Installation

1. Ensure you have the necessary dependencies installed, including [ESX](https://github.com/ESX-Org/es_extended).
2. Copy the script files to your server resources.
3. Add the script to your `server.cfg` file.

## Configuration

The script offers customization through the `allowedPeds` table in the script file. This table defines the allowed peds for each player.

```lua
-- Table containing allowed peds for each player
local allowedPeds = {
    ["char1:iddemo"] = {"nameped_1", "nameped_2", "nameped_3"},  -- User 1
    ["char1:iddemo"] = {"nameped_1"}  -- User 2
}

-- List of allowed player identifiers access pedsmenu
local allowedIdentifiers = {
    "char1:iddemo",  -- User 1
    "char1:iddemo"   -- User 2
}
