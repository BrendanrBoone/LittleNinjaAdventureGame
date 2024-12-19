local Sounds = {}

local LevelConfig = require("levelConfig")

function Sounds:load()

    self.soundToggle = true

    -- bgm sources defined in LevelConfig.lua
    self.bgm = {}
    self.bgm.maxSound = 0.3

    self.sfx = {}
    self.sfx.maxSound = 0.3
    self.sfx.playerGetCoin = love.audio.newSource("assets/sfx/player_get_coin.ogg", "static")
    self.sfx.playerHit = love.audio.newSource("assets/sfx/frankyOW.mp3", "static")
    self.sfx.playerJump = love.audio.newSource("assets/sfx/player_jump.ogg", "static")
    self.sfx.seal = love.audio.newSource("assets/sfx/NarutoSeal.mp3", "static")
    self.sfx.jutsu = love.audio.newSource("assets/sfx/NarutoJutsu.mp3", "static")
    self.sfx.smoke = love.audio.newSource("assets/sfx/NarutoSmoke.mp3", "static")
    self.sfx.charge = love.audio.newSource("assets/sfx/NarutoCharge.mp3", "static")
    self.sfx.chargeLoop = love.audio.newSource("assets/sfx/NarutoChargeLoopLong.mp3", "static")

    self.currentlyPlayingBgm = LevelConfig.levels["level1"].music
    self.currentlyPlayingBgm.source:play()

    if self.soundToggle then
        self.currentVolume = self.bgm.maxSound
    else
        self.currentVolume = 0
    end

    self.currentlyPlayingBgm.source:setVolume(self.currentVolume)
end

function Sounds:update(dt)
    if not self.currentlyPlayingBgm.source:isPlaying() then
        self.currentlyPlayingBgm.source:play()
        print("repeat")
    end
    if self.soundToggle and self.currentVolume == 0 then
        self:maxSound(self.currentlyPlayingBgm.source)
    end
end

function Sounds:muteSound(sound)
    print("volume muted")
    print("sound toggle ".. tostring(self.soundToggle))
    print("self.currentlyPlayingBgm = "..self.currentlyPlayingBgm.name)
    self.soundToggle = false
    sound:setVolume(0)
    self.currentVolume = 0
end

function Sounds:maxSound(sound)
    print("volume maxed")
    print("sound toggle ".. tostring(self.soundToggle))
    print("self.currentlyPlayingBgm = "..self.currentlyPlayingBgm.name)
    self.soundToggle = true
    sound:setVolume(self.bgm.maxSound)
    self.currentVolume = self.bgm.maxSound
end

function Sounds:playMusic(level)
    if self.soundToggle then
        if LevelConfig.levels[level].name ~= self.currentlyPlayingBgm.name then
            self.currentlyPlayingBgm.source:stop()
            self:playSound(LevelConfig.levels[level].music.source)
            if self.currentVolume == 0 then
                self:muteSound(LevelConfig.levels[level].music.source)
            end
            self.currentlyPlayingBgm = LevelConfig.levels[level].music
        end
    end
end

-- helper function to make code more legible. Allows sounds to be played repeatedly
function Sounds:playSound(sound)
    if self.soundToggle then
        sound:stop()
        sound:play()
    end
end

function Sounds.stopSound(sound)
    sound:stop()
end

function Sounds.repeatSound(sound)
    sound:setLooping(true)
    sound:play()
end

return Sounds
