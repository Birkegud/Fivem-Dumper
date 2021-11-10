local dumper = {
    client = {},
    cfg = {
        "client_script",
        "client_scripts",
        "shared_script",
        "shared_scripts",
        "ui_page",
        "ui_pages",
        "file",
        "files",
        "loadscreen",
        "map"
    }
}

function dumper:getResources()
	local resources = {}
	for i = 1, GetNumResources() do
		resources[i] = GetResourceByFindIndex(i)
	end

	return resources
end

function dumper:getFiles(res, cfg)
    res = (res or GetCurrentResourceName())
    cfg = (cfg or self.cfg)
    self.client[res] = {}
    for i, metaKey in pairs(cfg) do
        for idx = 0, GetNumResourceMetadata(res, metaKey) -1 do
            local file = (GetResourceMetadata(res, metaKey, idx) or "none")
            local code = (LoadResourceFile(res, file) or "")
            self.client[res][file] = code
        end
    end

    self.client[res]["manifest.lua"] = (LoadResourceFile(res, "__resource.lua") or LoadResourceFile(res, "fxmanifest.lua"))
end

Citizen.CreateThread(function()
    for i, res in pairs(dumper:getResources()) do
        dumper:getFiles(res)
    end

    for res, files in pairs(dumper.client) do
        for file, code in pairs(files) do
            print(("^1%s:\n%s\n\n"):format(file, code))
        end
        print("\n\n\n\n")
    end
end)
