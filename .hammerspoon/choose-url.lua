
local homePath="/Users/yoomlam"

local urlChoices = {

  { text="HackMD Paste", subText="https://hackmd.io/7rOGpNipTn-43y-_F71NeA"},
  { text="Google Calendar", subText="https://calendar.google.com/calendar/r/week"},
  { text="Google Keep", subText="https://keep.google.com/?q=hist#home"},
  { text="Google Drive", subText="https://drive.google.com/drive/my-drive"},
  { text="Alisa 1:1", subText="https://docs.google.com/document/d/1jx9dIA9qS-8a8xjYhDktQ20hmWTl8KMWqcNiJNM488Q/edit#" },
  { text="Music", subText="https://www.youtube.com/watch?v=J_S-ENCSNus"},
  { text="Citrix (CAG)", subText="https://citrixaccess.va.gov/vpn/index_citrix_splash.html" },
  { text="Pull Requests", subText="https://github.com/department-of-veterans-affairs/caseflow/pulls/yoomlam" },
  { text="Zenhub", subText="https://github.com/department-of-veterans-affairs/caseflow/issues/13175#workspaces/caseflow-5915dd178f67e20b5553ba0c/board?repos=51449239,79498890" },
  { text="Ticket Estimation", subText="https://hackmd.io/th85ORHnR8GIxJUVTkhpjw?edit" },
  { text="Hammerspoon docs", subText="https://www.hammerspoon.org/docs"},
  { text="Finder Desktop", subText="file://"..homePath.."/Desktop" },
  { text="Finder Documents", subText="file://"..homePath.."/Documents" },
  { text="Finder Downloads", subText="file://"..homePath.."/Downloads" },
  { text="Finder NOBACKUP", subText="file://"..homePath.."/NOBACKUP" },
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
