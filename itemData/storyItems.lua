local StoryItems = {}

-- RIGHT NOW STORY ITEMS ARE PRIMARILY USED TO CONTROL WHERE NPC SHOW UP

StoryItems.princessPass = {
    displayName = "Princess Pass",
    description = "For rescuing the princess you get the princess pass which allows you access to the castle",
    itemName = "princessPass",
    iconImg = "assets/itemIcons/princessPassIcon.png"
}

StoryItems.soldierBadge = {
    displayName = "Soldier Badge",
    description = "Looks like the soldier gave you his badge for keepsake",
    itemName = "soldierBadge",
    iconImg = "assets/itemIcons/soldierBadge.png"
}

StoryItems.gatePass = {
    displayName = "Gate Pass",
    description = "Pass to freely go through the castle gate.",
    itemName = "gatePass",
    iconImg = "assets/itemIcons/gatePass.png"
}

return StoryItems