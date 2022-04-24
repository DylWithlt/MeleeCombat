local Keybinds = {}

local CAS = game:GetService("ContextActionService")

Keybinds.Binds = {}

function Keybinds.BindKey(actionName, func, touchButton, ...)
    CAS:BindAction(actionName, func, touchButton, ...)
end

function Keybinds.Unbind(actionName)
    CAS:UnbindAction(actionName)
end

return Keybinds