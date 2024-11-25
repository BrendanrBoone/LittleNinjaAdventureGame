-- jutsu recipes with the seals

local Recipes = {}

local Helper = require("helper")

function Recipes:load()
    self.jutsu = {
        {name = "fireRelease", sequence = {"fireSeal"}},
        {name = "waterRelease", sequence = {"waterSeal"}},
        {name = "windRelease", sequence = {"windSeal"}}
    }
end

function Recipes:loadAssets()

end

function Recipes:loadHitboxes()

end

-- @param seq: array
-- @return string | nil
function Recipes:checkSequence(seq)
    for i=1, #self.jutsu do
        if Helper.checkTablesAreEqual(seq, self.jutsu[i].sequence) then
            return self.jutsu[i].name
        end
    end
    return nil
end

return Recipes