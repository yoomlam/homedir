-- https://www.hammerspoon.org/Spoons/URLDispatcher.html
local urlDispatcher=hs.loadSpoon("URLDispatcher")

local myUrlMapping = {}

function myUrlMapping:addUrlPatterns(bundleId, patterns)
  for i, pattern in ipairs(patterns) do
    table.insert(self, { pattern, bundleId })
  end
  -- print(hs.inspect(self))
end

function myUrlMapping:addFuncForUrlPatterns(openFunc, patterns)
  for i, pattern in ipairs(patterns) do
    table.insert(self, { pattern, nil, openFunc })
  end
  -- print(hs.inspect(self))
end

-- To find bundleId, open app's content and look for "bundleId" in a plist file

myUrlMapping:addUrlPatterns("org.mozilla.firefox", {
})
myUrlMapping:addUrlPatterns("com.google.Chrome", {
  "citrixaccess.va.gov",
  "caseflowdemo.com",
})
myUrlMapping:addUrlPatterns("com.microsoft.edgemac", {
  ".*%.sharepoint.com",".*%.office.com",".*%.outlook.com",
  "coderpad.io",
  "app.zenhub.com",
  "app.circleci.com",
  "caseflow.statuspage.io",
  "slack.com",
  "github.com",
  "github.io",
  "google.com",
  ".*%.gle",
  "sentry.ds.va.gov",
  "app.datadoghq.com",
  "hire.lever.co",
  "www.tms.va.gov",
  "amazonaws-us-gov.com",
  ".*%.paylocity.com",
  ".*%.va%.gov",
  "compute.internal",
  "app.retrium.com",
  "latticehq.com",
  "hackmd.io",
  "max.gov",
  "easyretro.io",
  "notion.so","notion.site",
  "mural.co",
  "nava-pbc.team.eden.io",
  "localhost",
  -- "localhost:3000",
  "localhost:6006",
  "localhost:1313",
  "verbose-broccoli-9868be41",
  "depo-platform-documentation.scrollhelp.site",
  "atlassian.net",
  "app.snyk.io",
  "ghcr.io",
  "scrollhelp.site",
  "zoom.us",
  "eden.io",
  "microsoft.com"
})
-- myUrlMapping:addUrlPatterns("us.zoom.xos", { "zoom.us" })

-- For testing
local function openFunc(arg)
  print("openFunc: "..hs.inspect(arg))
end
myUrlMapping:addFuncForUrlPatterns(openFunc, { "hello" })

---

local obj = {}

function obj:start()
  urlDispatcher.url_patterns = myUrlMapping
  urlDispatcher:start()
end

return obj
