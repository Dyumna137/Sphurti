local M = {}

function M.setup()
  local jdtls = require("jdtls")
  local home = "C:/Users/RITABRATA"
  local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
  local launcher_pattern = jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"
  local launcher_jar = vim.fn.glob(launcher_pattern)

  if launcher_jar == "" then
    vim.notify("Launcher JAR not found: " .. launcher_pattern, vim.log.levels.ERROR)
    return
  end

  local workspace_dir = home .. "/.cache/jdtls/workspace/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  vim.fn.mkdir(workspace_dir, "p") -- make sure directory exists

  local config = {
    cmd = {
      "C:/Users/RITABRATA/scoop/apps/openjdk17/current/bin/java",
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-javaagent:" .. jdtls_path .. "/lombok.jar",
      "-Xms1g",
      "-Xmx2G",
      "-jar", launcher_jar,
      "-configuration", jdtls_path .. "/config_win",
      "-data", workspace_dir,
    },
    root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
    settings = {
      java = {},
    },
    init_options = {
      bundles = {}
    },
  }

  jdtls.start_or_attach(config)
end

return M
