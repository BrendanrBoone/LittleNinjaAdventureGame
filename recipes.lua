-- jutsu recipes with the seals

local Recipes = {}

local Helper = require("helper")

function Recipes:load()
    self.jutsu = {
        {name = "fireAttribute", sequence = {"fireSeal"}},
        {name = "waterAttribute", sequence = {"waterSeal"}},
        {name = "windAttribute", sequence = {"windSeal"}}
    }
end

-- @param seq: array
-- @return string | nil
function Recipes:checkSequence(seq)
    for i=1, #self.jutsu do
        print("seq: "..tostring(seq))
        print("i jutsu: "..tostring(self.jutsu[i].sequence))
        if Helper.checkTablesAreEqual(seq, self.jutsu[i].sequence) then
            return self.jutsu[i].name
        end
    end
    return nil
end

return Recipes