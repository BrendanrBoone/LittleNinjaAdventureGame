local LevelConfig = {}

function LevelConfig:loadAssets()
    self.backgrounds = {
        oceanHighBackground = love.graphics.newImage("assets/oceanBackground.png"),
        skyBlueBackground = love.graphics.newImage("assets/background.png"),
        redBackground = love.graphics.newImage("assets/redBackground.png"),
        blackBackground = love.graphics.newImage("assets/blackBackground.jpg"),
        desertBackground = love.graphics.newImage("assets/desertBackground.png"),
        desertBackground2 = love.graphics.newImage("assets/desertBackground2.png"),
        desertBackground3 = love.graphics.newImage("assets/desertBackground3.png")
    }

    -- bgm defined in LevelConfig for easier access
    self.bgms = {
        OathHeart = love.audio.newSource("assets/bgm/OathOfTheHeart_inazumaElevenOST.mp3", "stream"),
        NakamaNoShirushi = love.audio.newSource(
        "assets/bgm/One Piece OST - Nakama no Shirushi da! Sign Of Friendship.mp3", "stream"),
        NarutoOst2 = love.audio.newSource("assets/bgm/Naruto OST 2 - Sasuke's Theme.mp3", "stream"),
        dragonTheme = love.audio.newSource("assets/bgm/dragonTheme.mp3", "stream"),
        dragonThemeSnore = love.audio.newSource("assets/bgm/dragonThemeSnore.mp3", "stream"),
        dragonThemeSnoreLouder = love.audio.newSource("assets/bgm/dragonThemeSnoreLouder.mp3", "stream")
    }

    self.levels = {
        level1 = {
            next = "castleCourtyard",
            prev = nil,
            background = self.backgrounds.desertBackground,
            music = {
                name = "NarutoOst2",
                source = self.bgms.NarutoOst2
            }
        },
        dragonDen = {
            next = nil,
            prev = nil,
            background = self.backgrounds.blackBackground,
            music = {
                name = "dragonThemeSnoreLouder",
                source = self.bgms.dragonThemeSnoreLouder
            }
        },
        castleCourtyard = {
            next = nil,
            prev = "level1",
            background = self.backgrounds.desertBackground,
            music = {
                name = "OathHeart",
                source = self.bgms.OathHeart
            }
        }
    }
end

return LevelConfig
