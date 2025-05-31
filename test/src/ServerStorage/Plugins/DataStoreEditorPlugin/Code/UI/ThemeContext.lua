local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local Theme = require(script.Parent.Theme)

local ThemeContext = Roact.createContext(Theme:Get())

return ThemeContext