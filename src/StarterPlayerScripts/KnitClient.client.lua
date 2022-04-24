local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

Knit.AddControllers(ReplicatedStorage.Source.Controllers)

Knit.Start():catch(warn)
-- Knit.Start() returns a Promise, so we are catching any errors and feeding it to the built-in 'warn' function
-- You could also chain 'await()' to the end to yield until the whole sequence is completed:
--    Knit.Start():catch(warn):await()