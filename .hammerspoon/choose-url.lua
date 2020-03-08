
local homePath="/Users/yoomlam"

local urlChoices = {
  { text="Echo Sandbox", subText="https://docs.google.com/document/d/1ERFk3HXo-1gn6f2d7_f_ThsMW5ZYe6BcDJmttzAH0C0/edit"},
  { text="Alisa 1:1", subText="https://docs.google.com/document/d/1jx9dIA9qS-8a8xjYhDktQ20hmWTl8KMWqcNiJNM488Q/edit#" },
  { text="Music", subText="https://www.youtube.com/watch?v=J_S-ENCSNus"},
  { text="Citrix (CAG)", subText="https://citrixaccess.va.gov/vpn/index_citrix_splash.html" },
  { text="Pull Requests", subText="https://github.com/department-of-veterans-affairs/caseflow/pulls/yoomlam" },
  { text="Zenhub", subText="https://github.com/department-of-veterans-affairs/caseflow/issues/13175#workspaces/caseflow-5915dd178f67e20b5553ba0c/board?repos=51449239,79498890" },
  { text="Ticket Estimation", subText="https://hackmd.io/th85ORHnR8GIxJUVTkhpjw?edit" },
  { text="Hammerspoon docs", subText="https://www.hammerspoon.org/docs"},
  { text="Hammerspoon init.lua", subText="file:///"..homePath.."/.hammerspoon/init.lua" },
  { text="Finder Desktop", subText="file://"..homePath.."/Desktop" },
  { text="Finder Documents", subText="file://"..homePath.."/Documents" },
  { text="Finder Downloads", subText="file://"..homePath.."/Downloads" },
}

local function openUrl(choice)
  if choice then
    -- print(hs.inspect(choice));
    hs.urlevent.openURL(choice['subText'])
  end
end

---

obj={}

function obj:showUrlChooser()
  exitModal()
  showChooser(urlChoices, openUrl)
end

return obj