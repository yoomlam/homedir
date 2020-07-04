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

myUrlMapping:addUrlPatterns("org.mozilla.firefox", {
  "github.com",
  "dsva.slack.com",
  "app.zenhub.com",
  "app.circleci.com",
  ".*amazonaws-us-gov.com",
  "caseflow.statuspage.io",

})
myUrlMapping:addUrlPatterns("com.google.Chrome", {
  "google.com",
  ".*%.gle",
  "citrixaccess.va.gov",
  "sentry.ds.va.gov",
  "app.datadoghq.com",
  "www.getclockwise.com",
  "coderpad.io",
  "hire.lever.co",
  "www.tms.va.gov",
  "airtable.com",
  ".*%.amazonaws-us-gov%.com",
  ".*%.pagerduty%.com",
  ".*%.newrelic%.com",
  ".*%.va%.gov",
  "caseflowdemo.com",
  "app.retrium.com",
  "latticehq.com",
  "hackmd.io"
})
myUrlMapping:addUrlPatterns("us.zoom.xos", { "zoom.us" })

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
