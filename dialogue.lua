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

return Dialogue