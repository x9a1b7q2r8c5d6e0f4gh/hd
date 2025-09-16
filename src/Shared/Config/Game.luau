local RunService = game:GetService("RunService")
return {
    CashFromPlacing = 1,
    PowerupDuration = 20,
    CashFromKilling = 3,

    FixedMode = false,
    TeamSwitchingEnabled = false,
    TeamMaxPlayers = game.Players.MaxPlayers/2,

    MainPlace = 137054753382840,

    NewPlayersPlaceId = 134427882546372,
    NewPlayersPlaceEnabled = false,
    NewPlayersStatLimit = 5,

    IsPrivateServer = RunService:IsServer() and (game.PrivateServerId and game.PrivateServerId ~= '')
}