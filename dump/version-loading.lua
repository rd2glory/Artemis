local inBeta = true
local version = "1.0"

loadstring(game:HttpGet("https://raw.githubusercontent.com/iamtryingtofindname/Artemis/main/releases/"..((inBeta and "beta") or "")..version..".lua"))()
