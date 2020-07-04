
local clipChoices = {
  { text="rrr", subText="```ruby``` markup",
    clip=[[```ruby
```]] },
  { text="fw", subText="recursive grep for whole word",
    clip="fw(){ grep --line-number --color --exclude-dir=.git --exclude-dir=node_modules -rw ${1:-SOMEWORD} . }" },
  { text="hist", subText="irb hist",
    clip="def hist; puts *(Readline::HISTORY.to_a); end" },
  { text="quiet", subText="logger.level = :warn",
    clip="ActiveRecord::Base.logger.level = :warn" },
  { text="curr", subText="set RequestStore[:current_user]",
    clip="RequestStore[:current_user] = User.system_user" },
  { text="rc", subText="Certification: Rails console",
    clip="sudo su -c \"source /opt/caseflow-certification/caseflow-certification_env.sh; cd /opt/caseflow-certification/src; IRBRC=/tmp/my_repl.rb bin/rails c\"" },
  { text="rhelp", subText="Ruby helper functions",
    clip=[[def uuid?(uuid)
  uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
  uuid_regex.match?(uuid.to_s.downcase)
end
def quietly
  saved_logger_level = ActiveRecord::Base.logger.level
  ActiveRecord::Base.logger.level = :warn
  ret_value = yield
  ActiveRecord::Base.logger.level = saved_logger_level
  ret_value
end
def appeal(obj)
  appeal = obj if obj.is_a?(Appeal) || obj.is_a?(LegacyAppeal)
  appeal = uuid?(obj) ? Appeal.find_by(uuid: obj) : LegacyAppeal.find_by(vacols_id: obj) if appeal.nil?
end
]] },
}

local function pasteClip(choice)
  if choice then
    if choice['clip'] then
      hs.pasteboard.setContents(choice['clip'])
      hs.eventtap.keyStroke({"cmd"}, "v")
      -- hs.eventtap.keyStrokes(choice['clip'])
    elseif choice['funcKey'] then
      KEY_FUNC_MAP[choice['funcKey']]()
    else
      apps:newWindow(choice['subText'])
    end
  end
end

---

obj={}

function obj:showClipChooser()
  exitModal()
  showChooser(clipChoices, pasteClip)
end

return obj
