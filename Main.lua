local Dumper = {
    Client = {}
}

function Dumper:PrintTable(Table)
    for k, v in pairs(Table) do
        if type(v) == "table" then
            self:PrintTable(v)
        else
            print(k, v)
        end
    end
end

function Dumper:GetResources()
	local resources = {}
	for i = 1, GetNumResources() do
		resources[i] = GetResourceByFindIndex(i)
	end

	return resources
end

function Dumper:GetFiles(Resource, File, Side)
	if not File then return end
    if not Side then Side = "Client" end
    local Files = {}
    local Code = LoadResourceFile(Resource, File)
    if not Code then return Files end

    local RegexTable = {
        Server = {
            "server_scripts% {.-%}",
			"server_script% {.-%}",
			"server_script% '.-%'",
			'server_script% ".-%"',
			"server_scripts%{.-%}",
			"server_script%{.-%}"
        },
        Client = {
            "client_scripts% {.-%}",
			"client_script% {.-%}",
			"client_script% '.-%'",
			'client_script% ".-%"',
			"client_script%{.-%}",
			"client_scripts%{.-%}"
        },
        CleanUp = {
            "'.-'",
            '".-"'
        }
    }

    for k, Regex in pairs(RegexTable[Side]) do
        for Match in string.gmatch(Code, Regex) do
            for k, CleanRegex in pairs(RegexTable["CleanUp"]) do
                for Cleaned_Match in string.gmatch(Match, CleanRegex) do
                    Cleaned_Match = string.gsub(Cleaned_Match, '"', "")
                    Cleaned_Match = string.gsub(Cleaned_Match, "'", "")
                    table.insert(Files, Cleaned_Match)
                end
            end
        end
    end

    return Files
end

function Dumper:GetStartFile(Resource)
	if Resource == nil then return end
	if LoadResourceFile(Resource, "fxmanifest.lua") ~= nil then
		return "fxmanifest"
	elseif LoadResourceFile(Resource, "__resource.lua") ~= nil then
		return "__resource"
	else
		return ""
	end
end

function Dumper:ClientDump(Resource)
    if not Resource then Resource = "All" end
    if Resource:lower() == "all" then
        for k, ResourceName in pairs(self:GetResources()) do
            local Files = self:GetFiles(ResourceName, self:GetStartFile(ResourceName) .. ".lua")
            self["Client"][ResourceName] = {}
            for k, FileName in pairs(Files) do
                self["Client"][ResourceName][FileName] = LoadResourceFile(ResourceName,  FileName)                
                if LoadResourceFile(ResourceName,  FileName) == nil or "" then
                    print("ClientDump: The File: " .. FileName .. " in the resource: " .. Resource .. " was nil")
                end
            end
        end
    else
        local Files = self:GetFiles(Resource, self:GetStartFile(Resource) .. ".lua")
        for k, FileName in pairs(Files) do
            self["Client"][Resource] = {}
            self["Client"][Resource][FileName] = LoadResourceFile(Resource,  FileName)
            if LoadResourceFile(Resource,  FileName) == nil or "" then
                print("ClientDump: The File: " .. FileName .. " in the resource: " .. Resource .. " was nil")
            end
        end
    end
end

Dumper:ClientDump()

Dumper:PrintTable(Dumper.Client)