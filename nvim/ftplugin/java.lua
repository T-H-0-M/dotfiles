local function ensure_jdtls()
	local ok, jdtls = pcall(require, "jdtls")
	if ok then
		return jdtls
	end

	local ok_lazy, lazy = pcall(require, "lazy")
	if ok_lazy then
		pcall(lazy.load, { plugins = { "nvim-jdtls" } })
		ok, jdtls = pcall(require, "jdtls")
		if ok then
			return jdtls
		end
	end

	return nil
end

local jdtls = ensure_jdtls()
if not jdtls then
	return
end

local root_dir = require("jdtls.setup").find_root({ "pom.xml", "mvnw", ".git" })
if not root_dir then
	return
end

local project_name = vim.fs.basename(root_dir)
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. project_name
if vim.fn.exists("*sha256") == 1 then
	workspace_dir = workspace_dir .. "-" .. vim.fn.sha256(root_dir):sub(1, 8)
end

local data_dir = vim.fn.stdpath("data")
local lombok_jar = data_dir .. "/mason/packages/jdtls/lombok.jar"
local uv = vim.uv or vim.loop

local cmd = { "jdtls" }
if uv.fs_stat(lombok_jar) then
	table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok_jar)
end
vim.list_extend(cmd, { "-data", workspace_dir })

local config = {
	cmd = cmd,
	root_dir = root_dir,
	settings = {
		java = {
			configuration = {
				updateBuildConfiguration = "interactive",
			},
			maven = {
				downloadSources = true,
			},
			eclipse = {
				downloadSources = true,
			},
		},
	},
	init_options = {
		bundles = {},
	},
}

local ok_cmp, blink_cmp = pcall(require, "blink.cmp")
if ok_cmp and type(blink_cmp.get_lsp_capabilities) == "function" then
	config.capabilities = blink_cmp.get_lsp_capabilities()
end

jdtls.start_or_attach(config)
