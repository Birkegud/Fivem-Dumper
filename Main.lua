local dumper = {
    client = {},
    triggers = {}
}

function dumper:getResources()
	local resources = {}
	for i = 1, GetNumResources() do
		resources[i] = GetResourceByFindIndex(i)
	end

	return resources
end

function dumper:getFiles(resource, file, side)
	if not file then return end
    if not side then side = "Client" end
    local files = {}
    local code = LoadResourceFile(resource, file)
    if not code then return files end

    local regexTable = {
        Client = {
            "client_scripts% {.-%}",
			"client_script% {.-%}",
			"client_script% '.-%'",
			'client_script% ".-%"',
			"client_script%{.-%}",
			"client_scripts%{.-%}",
			"loadscreen%{.-%}",
            "loadscreen% {.-%}",
			"ui_page%{.-%}",
            "ui_page% {.-%}",
			"file%{.-%}",
            "file% {.-%}",
			"files%{.-%}",
            "files% {.-%}",
            "shared_script%{.-%}",
            "shared_script% {.-%}"
        },
        CleanUp = {
            "'.-'",
            '".-"'
        }
    }

    for k, regex in pairs(regexTable[side]) do
        for m in string.gmatch(code, regex) do
            for k, cleanRegex in pairs(regexTable["CleanUp"]) do
                for cleaned_Match in string.gmatch(m, cleanRegex) do
                    cleaned_Match = string.gsub(cleaned_Match, '"', "")
                    cleaned_Match = string.gsub(cleaned_Match, "'", "")
                    table.insert(files, cleaned_Match)
                end
            end
        end
    end

    return files
end

function dumper:getStartFile(resource)
	if resource == nil then return end
	if LoadResourceFile(resource, "fxmanifest.lua") ~= nil then
		return "fxmanifest"
	elseif LoadResourceFile(resource, "__resource.lua") ~= nil then
		return "__resource"
	else
		return ""
	end
end

function dumper:getTriggers(code)
    local regexs = {"TriggerServerEvent%(.-%)"}
    local triggers = {}
    for k, r in pairs(regexs) do
        for m in string.gmatch(code, r) do
            table.insert(triggers, m)
        end
    end

    return triggers
end

function dumper:printTable(table)
    for k, v in pairs(table) do
        if type(v) == "table" then
            self:printTable(v)
        else
            print(k, v)
        end
    end
end

function dumper:clientDump(resource)
    local startFile = self:getStartFile(resource)
    local files = self:getFiles(resource, startFile .. ".lua")
    local dumpedFiles = {}
    for i, file in pairs(files) do
        local code = LoadResourceFile(resource, file)
        if code then
            local triggers = self:getTriggers(code)
            dumpedFiles[file] = {["code"] = code, ["triggers"] = triggers}
        end
    end

    return dumpedFiles
end

for i, r in pairs(dumper:getResources()) do
    dumper.client[r] = dumper:clientDump(r)
end

dumper:printTable(dumper.client)
