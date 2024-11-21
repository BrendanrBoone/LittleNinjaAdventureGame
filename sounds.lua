local Sounds = {}

function Sounds:load()

    self.soundToggle = true

    self.bgm = {}
    self.bgm.maxSound = 0.3
    self.bgm.OathHeart = love.audio.newSource("assets/bgm/OathOfTheHeart_inazumaElevenOST.mp3", "stream")
    self.bgm.NakamaNoShirushi = love.audio.newSource(
        "assets/bgm/One Piece OST - Nakama no Shirushi da! Sign Of Friendship.mp3", "stream")

    self.sfx = {}
    self.sfx.maxSound = 0.3
    self.sfx.playerGetCoin = love.audio.newSource("assets/sfx/player_get_coin.ogg", "static")
    self.sfx.playerHit = love.audio.newSource("assets/sfx/frankyOW.mp3", "static")
    self.sfx.frankyEyeCatchTheme = love.audio.newSource("assets/sfx/frankyEyeCatchTheme.mp3", "static")
    self.sfx.playerJump = love.audio.newSource("assets/sfx/player_jump.ogg", "static")

    -- clear profiles necessary => {name, source}
    self.bgmLevels = {
        levelPreTutorial = {
            name = "OathHeart",
            source = self.bgm.OathHeart
        },
        levelTutorial = {
            name = "OathHeart",
            source = self.bgm.OathHeart
        },
        level2 = {
            name = "OathHeart",
            source = self.bgm.OathHeart
        },
        level3 = {
            name = "OathHeart",
            source = self.bgm.OathHeart
        },
        level4 = {
            name = "NakamaNoShirushi",
            source = self.bgm.NakamaNoShirushi
        },
        levelLighthouse = {
            name = "NakamaNoShirushi",
            source = self.bgm.NakamaNoShirushi
        },
        levelLighthouse2 = {
            name = "NakamaNoShirushi",
            source = self.bgm.NakamaNoShirushi
        }
    }
    self.currentlyPlayingBgm = self.bgmLevels["levelTutorial"]
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
        self.playSound(self.currentlyPlayingBgm.source)
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
        if self.bgmLevels[level].name ~= self.currentlyPlayingBgm.name then
            self.currentlyPlayingBgm.source:stop()
            self.playSound(self.bgmLevels[level].source)
            if self.currentVolume == 0 then
                self:muteSound(self.bgmLevels[level].source)
            end
            self.currentlyPlayingBgm = self.bgmLevels[level]
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

return Sounds
