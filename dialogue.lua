local Dialogue = {}

Dialogue.nicoRobin = {
    message = "Hey Franky!",
    sequence = {
        { "Player",    "sUUUpERRRRRRR!" },
        { "nicoRobin", "You seem excited. What are you doing?" },
        { "Player",    "sunny's in need of some repairs. I need to go collect wood for some patch work." },
        { "nicoRobin", "Oh! I wish you luck" },
        { "Player",    "OW!" },
        { nil, nil }
    }
}

Dialogue.princess = {
    message = "Hi",
    sequence = {
        { "princess", "Are you here to rescue me?" },
        { "Player",   "yup!" },
        { nil, nil }
    }
}

Dialogue.soldier = {
    message = "Hey",
    sequence = {
        { "soldier", "The princess is in danger!" },
        { "Player",   "What happened?" },
        { "soldier", "She was kidnapped by a dragon!" },
        { "soldier", "But the entrance is protected by some fire. Please..." },
        { "soldier", "save the princess." },
        { "soldier", "The dragon went into the cave ahead." },
        { "Player",   "I'm on it." },
        { nil, nil }
    },
    sequence2 = {
        { "soldier", "Thank goodness! I see you've rescued the Princess" },
        { "soldier", "Please have this GATE PASS and escort her inside" },
        { "Player", "ok!" },
        { nil, nil }
    }
}

return Dialogue