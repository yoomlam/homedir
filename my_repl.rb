# frozen_string_literal: true

# Usage:
# If rails console opens a PRY REPL, do one of these:
#   * add `load "path/to/this/file"` to .pryrc
#   * have this file be .pryrc or linked as .pryrc
# If rails console opens an IRB REPL, you have options:
#   * On the command prompt, `IRBRC='path/to/this/file' bin/rails c`
#     See https://github.com/department-of-veterans-affairs/appeals-deployment/pull/2810#
#   * Within the IRB prompt, `load "path/to/this/file"`
#   * On the command prompt, run `PRYRC="path/to/this/file" rails console`
#     Then within the IRB console, `require 'pry'; pry`
#   * On command prompt, `bin/rails c -- 'path/to/this/file'` # Ctrl-C causes exception
#
# https://github.com/department-of-veterans-affairs/caseflow/wiki/Rails-Console-Code-Snippets

puts "Loading #{File.expand_path(__FILE__)} ..."

# https://github.com/microsoft/terminal/issues/2520#issuecomment-577030936
# {
#   "\000H" => :rl_get_previous_history, # Up
#   "\000P" => :rl_get_next_history, # Down
#   "\000M" => :rl_forward_char,  # Right
#   "\000K" => :rl_backward_char, # Left
#   "\000G" => :rl_beg_of_line,   # Home
#   "\000O" => :rl_end_of_line,   # End
#   "\000s" => :rl_backward_word, # Ctrl-Left
#   "\000t" => :rl_forward_word, # Ctrl-Right
#   "\000S" => :rl_delete, # Delete
#   "\000R" => :rl_overwrite_mode # Insert
# }.each do |keyseq, method|
#   Readline.rl_bind_keyseq_if_unbound(keyseq, method)
# end

def _my_prompt(color1, color2, color3, label)
  [
    proc { |target_self, nest_level, pry|
      "[#{pry.input_ring.size}] \001\e[0;#{color1}m\002#{label}" \
        "\001\e[0m\002(\001\e[0;#{color3}m\002#{Pry.view_clip(target_self)}" \
        "\001\e[0m\002)#{":#{nest_level}" unless nest_level.zero?}> "
    },
    proc { |target_self, nest_level, pry|
      "[#{pry.input_ring.size}] \001\e[1;#{color2}m\002#{label}" \
        "\001\e[0m\002(\001\e[1;#{color3}m\002#{Pry.view_clip(target_self)}" \
        "\001\e[0m\002)#{":#{nest_level}" unless nest_level.zero?}_   "
    }
  ]
end

def _set_pry_prompt
  puts "    Configuring Pry.config.prompt"
  default_prompt = Pry::Prompt[:default]
  prompt_procs = case Rails.env
                 when "production"
                   _my_prompt(31, 34, 35, "#{Pry.config.prompt_name} prod")
                 when "development"
                   _my_prompt(36, 32, 33, "dev")
                 else
                   _my_prompt(36, 32, 33, "#{Pry.config.prompt_name} #{Rails.env}")
                      end
  Pry.config.prompt = Pry::Prompt.new("Yoom", "Yoom's prompt", prompt_procs)
end

def tiny_prompt
  sql_off
  # tiny_prompt=proc { "\001\e[0;35m\002> \001\e[0m\002" }
  tiny_prompt = [
    proc { "\001\e[0;31m\002>\001\e[0m\002 " },
    proc { "\001\e[0;31m\002 \001\e[0m\002 " }
  ]
  Pry.config.prompt = Pry::Prompt.new("Yoom tiny", "Yoom's tiny prompt", tiny_prompt)
  pry
end
# def no_prompt
#   cr_prompt=proc { |target_self, nest_level, pry|
#     "\n\# [#{pry.input_ring.size}] \001\e[1;32m\002#{Pry.config.prompt_name}\001\e[0m\002\n"
#   }
#   pry({ prompt: cr_prompt })
# end

def configure_pry
  puts "  Configuring Pry"
  _set_pry_prompt
  # Pry.config.pager = false
  Pry.config.commands.alias_command "hst", "hist --no-numbers"
  $PRY_CONFIGURED = true
end

## === Introspection ===========================

# print methods local to an object's class
# someobj.local_methods
def local_methods(obj = self)
  (obj.methods - Object.instance_methods).sort
end

def obj_inst_methods(obj = self)
  clazz = obj.is_a?(Class) ? obj : obj.class
  clazz.instance_methods(false).sort
end

def public_methods_without_parent(obj = self)
  (obj.public_methods - obj.class.superclass.methods).sort
end

IGNORED_PREFIXES = %w[_ before_ after_ autosave_].freeze
# ignore_prefixes(obj_inst_methods(obj))
# ignore_prefixes(methods_without_parent(obj))
def ignore_prefixes(methods)
  methods.reject do |m|
    IGNORED_PREFIXES.any? { |prefix| m.to_s.start_with?(prefix) }
  end
end

## === Debugging ============================

BACKTRACE_CLEANER = ActiveSupport::BacktraceCleaner.new
BACKTRACE_CLEANER.add_filter   { |line| line.gsub(Rails.root.to_s, ".") } # strip the Rails.root prefix
# BACKTRACE_CLEANER.add_silencer { |line| line =~ /gems|\/lib\/|\.rbenv\// } # skiplines
BACKTRACE_CLEANER.add_silencer { |line| line =~ /\.rbenv\// } # skiplines

def caller_
  # BACKTRACE_CLEANER.clean(exception.backtrace)
  BACKTRACE_CLEANER.clean(caller)
end

def create(*args)
  FactoryBot.create(*args)
end

## === Print tables ===========================

# Usage examples: print table transposed
#   print_table_t Video.where(key: '123'), :created_at, :updated_at, :published
#   print_table_t [album1, album2], :title, :image_count
def print_table_t(objects, *method_names)
  terminal_width = `tput cols`.to_i
  cols = objects.count + 1 # Label column
  col_width = (terminal_width / cols) - 1 # Column spacing

  Array(method_names).map do |method_name|
    cells = objects.map { |o| o.send(method_name).inspect }
    cells.unshift(method_name)

    puts cells.map { |cell| cell.to_s.ljust(col_width) }.join " "
  end
  nil
end

# -------------------------------
# col_labels = { date: "Date", from: "From", subject: "Subject" }
# arr = [{date: "2014-12-01", from: "Ferdous", subject: "Homework this week"},
#        {date: "2014-12-01", from: "Dajana", subject: "Keep on coding! :)"},
#        {date: "2014-12-02", from: "Ariane", subject: "Re: Homework this week"}]
# col_labels = { created_at: "create", updated_at: "update", closed_at: "closed"}
# print_table col_labels, Appeal.last.tasks.order(:id)
def print_table(col_labels, arr)
  columns = derive_label_and_maxwidth(col_labels, arr)
  # => {:date=>    {:label=>"Date",    :width=>10},
  #     :from=>    {:label=>"From",    :width=>7},
  #     :subject=> {:label=>"Subject", :width=>22}}
  puts write_divider(columns, "+++")
  puts write_header(columns)
  puts write_divider(columns, "+++")
  arr.each { |h| puts write_line(columns, h) }
  puts write_divider(columns, "+++")
end

def derive_label_and_maxwidth(col_labels, arr)
  col_labels.each_with_object({}) do |(col, label), h|
    h[col] = { label: label,
               width: [arr.map { |g| g[col].to_s.size }.max, label.size].max }
  end
end

def write_line(columns, h, col_sep = "|")
  str = columns.keys.map do |k|
    h.send(k).to_s.ljust(columns[k][:width]).to_s
  end.join(" #{col_sep} ")
  "| #{str} |"
end

def write_header(columns, col_sep = "|")
  "| #{columns.map { |_, g| g[:label].ljust(g[:width]) }.join(" #{col_sep} ")} |"
end

def write_divider(columns, col_sep = "+|+")
  "#{col_sep[0]}-#{columns.map { |_, g| '-' * g[:width] }.join("-#{col_sep[1]}-")}-#{col_sep[2]}"
end
# -------------------------------

## === TaskTreeRender ===========================

# $treee = {
#   renderer: TaskTreeRenderModule.global_renderer,
#   attrs: TaskTreeRenderModule.global_renderer.config.default_atts,
#   config: TaskTreeRenderModule.global_renderer.config
# }

# def treee_compact
#   TaskTreeRenderModule.global_renderer.compact_mode
# end

# def treee_attrs(*atts)
#   TaskTreeRenderModule.global_renderer.config.tap do |conf|
#     conf.default_atts = *atts
#   end
# end

# def treee_add_attrs(*atts)
#   treee_attrs(*($treee[:attrs] + atts))
# end

## === AWS helpers ============================

# copy_to_s3("/opt/caseflow-certification/src/hearings2.csv", "temp/hearings2.csv", bucket_name: "dsva-appeals-caseflow-prod")
def copy_to_s3(filepath, filename, bucket_name: Rails.application.config.s3_bucket_name)
  Aws.config.update(region: "us-gov-west-1")
  $s3_client ||= Aws::S3::Client.new
  $s3_resource ||= Aws::S3::Resource.new(client: $s3_client)
  bucket = $s3_resource.bucket(bucket_name)

  bucket.object(filename).upload_file(filepath, acl: "private", server_side_encryption: "AES256")
end

## === Ruby helpers ============================

def split_into_weeks(time_span)
  week = time_span.begin..time_span.begin.end_of_week
  time_periods = [week]
  while week.begin.next_week.end_of_week < time_span.end
    week = week.begin.next_week..week.begin.next_week.end_of_week
    time_periods << week
  end
  time_periods << (week.begin.next_week..(time_span.end - 1))
end

## === query helpers ============================

# find Post which has more than one Comments:
# Post.joins(:comments).group('posts.id').having('count(comments.id) > ?', 1)
# Appeal.active.where(aod_reason: nil).joins(claimants: :person).where("people.date_of_birth <= ?", 75.years.ago)

# cs=Claimant.joins(:person).where("people.date_of_birth <= ?", 75.years.ago).where(decision_review_type: :Appeal)
# cs.group(:type).count

def groupby_date(query, period: "month", column: "updated_at")
  query.group("DATE_TRUNC('#{period}', #{column})").count.sort_by { |key, _v| key || Time.utc(1900) }.to_h
end

def groupby_date_string(query, ftime: "%Y-%m", column: "updated_at")
  # query.group_by{|h| "#{h[column]&.strftime(ftime)}"}.map{|k,v| [k,v.size]}.to_h.sort_by{|key, v| key}.to_h
  query.group_by { |h| h[column]&.strftime(ftime).to_s }.transform_values(&:count).sort_by { |key, _v| key }.to_h
end

def barchart(query, column: "updated_at", tick: "*")
  query.order(column).map { |u| u[column]&.strftime("%Y-%m") }.reduce(Hash.new(0)) do |a, b|
    a[b] = a.key?(b) ? a[b] + "-" : "-"; a
  end
end

def count_freq(arr)
  arr.each_with_object(Hash.new(0)) { |obj, counts| counts[obj] += 1 }
end

## === helper methods ============================

def uuid?(uuid)
  uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
  uuid_regex.match?(uuid.to_s.downcase)
end

$SAVED_LOGGER_LEVEL = ActiveRecord::Base.logger.level if defined?(Rails)
def sql_off
  ActiveRecord::Base.logger.level = :warn
end

def sql_on
  ActiveRecord::Base.logger.level = $SAVED_LOGGER_LEVEL
end

def sql_debug
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

# require "anbt-sql-formatter/formatter"
def sql_(query)
  puts formatter.format(query.dup)
end

# Suppress SQL queries to reduce console clutter
$NESTED_QUIETLY = 0
def quietly
  sql_off if $NESTED_QUIETLY == 0
  $NESTED_QUIETLY += 1
  ret_value = yield
  $NESTED_QUIETLY -= 1
  sql_on if $NESTED_QUIETLY == 0
  ret_value
end

def could_be_ssn?(ssn)
  ssn =~ /^[0-8]\d{8}$/
end

## ===========================

# # Prints a more readable version of PaperTrail versioning data
# # Usage: `pp _versions DistributionTask.last`
# def _versions(record)
#   record.try(:versions)&.map do |version|
#     {
#       who: [User.find_by_id(version.whodunnit)].compact
#         .map { |user| "#{user.css_id} (#{user.id}, #{user.full_name})" }.first,
#       when: version.created_at,
#       changeset: version.changeset
#     }
#   end
# end

# _versions
# def pt_(record)
#   puts record.versions&.map { |v|
#     [[User.find(v.whodunnit)].pluck(:css_id, :full_name).join(","),
#      v.object_changes.to_s]
#   }.join("====\n")
# end

## === Person ====================================

def p_vet(id)
  vet = Veteran.find_by_file_number_or_ssn(id)

  crs = ClaimReview.find_all_visible_by_file_number(vet.file_number)
  crs.each { |cr| p_claim_review(cr) }

  appeals = AppealFinder.find_appeals_with_file_numbers(vet.file_number)
  appeals.each { |a| p_appeal(a) }

  vet
end

def person_(id)
  person = Person.find(id) if id.is_a? Numeric
  return person if person

  persons = Person.where("UPPER(name) LIKE ?", "%#{id.upcase}%")
  return persons.first if persons.count == 1

  puts "Found #{persons.count} persons with name like %#{id.upcase}%: #{persons.map { |u| [u.id, u.name] }}"
end

# _user
# # user_ 3
# # user_ "BvaAAbshire"
# # user_ 'ABS'
# def user_(id)
#   user = User.find(id) if id.is_a? Numeric
#   return user if user

#   user = User.find_by(css_id: id.upcase) if id.is_a? String
#   return user if user

#   staff = VACOLS::Staff.find_by(slogid: id.upcase)
#   return User.find_by(css_id: staff.sdomainid) if staff

#   users = User.where("UPPER(full_name) LIKE ?", "%#{id.upcase}%")
#   return users.first if users.count == 1

#   puts "Found #{users.count} users with full_name like %#{id.upcase}%: #{users.map { |u| [u.css_id, u.full_name] }}"
# end

# def staff_(id)
#   return VACOLS::Staff.find_by(sdomainid: id.css_id) if id.is_a? User

#   staff = VACOLS::Staff.find_by(slogid: id.upcase)
#   return staff if staff

#   staff = VACOLS::Staff.find_by(sdomainid: id.upcase)
#   return staff if staff

#   staff = VACOLS::Staff.where("UPPER(slogid) LIKE ?", "%#{id.upcase}%")
#   return staff.first if staff.count == 1

#   puts "Found #{staff.count} staff with full_name like %#{id.upcase}%: #{staff.map { |u| [u.css_id, u.full_name] }}"
# end

# p_user user "BvaAAbshire"
def p_user(obj)
  quietly do
    user = obj if obj.is_a?(User)
    user = user(obj) if user.nil?

    puts UserRepository.user_info_from_vacols(user.css_id)
    puts UserRepository.user_info_for_idt(user.css_id)

    puts VACOLS::Staff.find_by_sdomainid(user.css_id)&.attributes

    # Can also run this on the command line such as
    # `CSS_ID=BVAAABSHIRE bundle exec rake users:footprint`
    pp UserReporter.new(user.css_id).report

    legacy_cases = VACOLS::Case.where(bfcurloc: user.vacols_user.slogid)
    puts "Legacy cases assigned to user: #{legacy_cases.count}"
    pp legacy_cases.pluck(:bfkey)

    user
  end
end

# Need to access external systems
# RequestStore[:current_user] = User.find_by_css_id("VACOLAMD")
def sysuser_
  RequestStore[:current_user] = User.system_user
end

# Set time zone in Rails console to mimic webapp
# Time.zone = "America/New_York"

# authenticate user
def auth_user(user)
  RequestStore[:current_user] = user
  # https://github.com/department-of-veterans-affairs/caseflow/wiki/Debugging-Tips#authenticating-in-the-rails-console
  User.authentication_service.user_session = User.authentication_service.get_user_session(user.id)
end

## === Veteran ====================================

# def vets_appeals(vet)
#   AppealFinder.new(user: User.system_user).find_appeals_for_veterans([vet])
# end

## === Appeal ====================================

# # appeal "1c11a1ae-43bd-449b-9416-7ccb9cb06c11"
# # appeal 1234567
# def appeal_(obj)
#   appeal = obj if obj.is_a?(Appeal) || obj.is_a?(LegacyAppeal)
#   appeal ||= uuid?(obj) ? Appeal.find_by(uuid: obj) : LegacyAppeal.find_by(vacols_id: obj)
# end

# alias _a _appeal
def _Appeal(id)
  Appeal.find(id)
end

# p_appeal appeal "f3c20696-9c28-4213-bcc3-cba93b6e6184"
def p_appeal(appeal)
  quietly do
    appeal.treee

    p_legacy_appeal(appeal) if appeal.is_a?(LegacyAppeal)

    AttorneyCaseReview.find_by(task_id: appeal.tasks.pluck(:id)).tap { |acr| puts acr&.inspect }

    JudgeCaseReview.find_by(task_id: appeal.tasks.pluck(:id)).tap { |jcr| puts "  #{jcr&.inspect}" }

    puts "---- #{appeal.hearings.count} Hearings"
    if defined? p_hearing
      appeal.hearings.each do |hearing|
        p_hearing(hearing)
      end
    end

    ris = appeal.issues
    ris = ris[:request_issues] if appeal.is_a?(Appeal)
    puts "---- #{ris.count} Request Issue(s)"
    p_request_issues(ris) if defined? p_request_issues && appeal.is_a?(Appeal)
    pp ris if appeal.is_a?(LegacyAppeal)

    rius = RequestIssuesUpdate.where(review: appeal)
    puts "---- #{rius.count} Request Issues Update(s)"
    if defined? p_request_issue_update
      rius.each_with_index do |riu, i|
        p_request_issue_update(riu, i)
      end
    end

    if appeal.is_a?(LegacyAppeal)
      decs = appeal.decisions
      puts "---- #{decs.count} Decision(s)"
      decs.each { |doc| puts "  #{doc&.inspect}" }
    end

    puts "---- Legacy appeals for vet "
    decision_revew = appeal
    decision_revew.serialized_legacy_appeals

    appeal
  end
end

# def legacy_(docket_number)
#   vids = VACOLS::Case.joins(:folder).where("folder.tinum": docket_number).pluck(:id)
#   LegacyAppeal.where(vacols_id: vids)
# end

# p_appeal appeal 3085659
def p_legacy_appeal(appeal)
  quietly do
    tasks = LegacyWorkQueue.tasks_by_appeal_id(appeal.vacols_id)
    puts "____________________"
    puts "---- Legacy Tasks"
    tasks.map do |t|
      puts "#{t.class.name}, assigned_by: #{t.assigned_by&.inspect} #{t.assigned_by&.sdomainid}, assigned_to: #{t.assigned_to&.inspect} #{t.assigned_to&.sdomainid}, at: #{t.assigned_at}\n"
    rescue StandardError
      puts "#{t.class.name}, assigned_by: #{t.assigned_by&.inspect}, assigned_to: #{t.assigned_to&.inspect}, at: #{t.assigned_at}\n"
    end

    puts "---- Prior Locations"
    puts "changed_at, change_to, changed_by, prior_loc"
    # pp appeal.location_history.pluck(:locdout, :locstto, :locstrcv, :locstout)
    pp appeal.location_history.map(&:summary)
    puts "^^^^^^^^^^^^^^^^^^^^"
    tasks
  end
end

## === Legacy appeal =============================

def legacies(vet)
  LegacyAppeal.fetch_appeals_by_file_number(vet.file_number).tap do |las|
    las.map  do |l|
      { nod: l.nod_date, soc: l.soc_date, ssoc: l.ssoc_dates,
        vacols_id: l.vacols_id, disposition: l.disposition }
    end
  end
end

# Get the data for a specific vacols issue, useful for validating results after making manual updates,
# because otherwise the issue will be memoized and may not show the current status
def vacols_issue(vacols_id, vacols_sequence_id)
  return unless vacols_id && vacols_sequence_id

  @vacols_issue ||= AppealRepository.issues(vacols_id).find do |issue|
    issue.vacols_sequence_id == vacols_sequence_id
  end
end

## === Hearing ===================================

def hearing_(id)
  Hearing.find_hearing_by_uuid_or_vacols_id(id)
end

# p_appeal appeal "3ee973ab-467e-46c6-9b0b-7c83e11ecd6c"
# p_hearing hearing "cbdde413-1461-4a64-a82e-06e8df147c2c"
def p_hearing(hearing)
  quietly do
    puts hearing.inspect
    if hearing.hearing_day
      puts "    Day:#{[hearing.hearing_day.scheduled_for, hearing.hearing_day.request_type, hearing.hearing_day.regional_office]}, " \
           "Judge:#{[hearing.judge.css_id, hearing.judge.full_name]}"
    end

    p_legacy_hearing(hearing) if hearing.is_a? LegacyHearing
  end
end

def p_legacy_hearing(_hearing)
  puts "TBD"
end

## === RequestIssue ================================

# # https://github.com/department-of-veterans-affairs/caseflow/wiki/Intake-Structure-Renderer
# require "./lib/helpers/intake_renderer.rb" unless defined? IntakeRenderer
# require "./lib/helpers/intake_renderable.rb" unless defined? IntakeRenderable
# IntakeRenderer.patch_intake_classes
# # puts decision_review.render_intake

# require "./lib/helpers/hearing_renderer.rb" unless defined? HearingRenderer
# require "./lib/helpers/hearing_renderable.rb" unless defined? HearingRenderable
# HearingRenderer.patch_hearing_classes
# # puts appeal.render_hearing
# # puts veteran.render_hearing
# # puts HearingRenderer.render(obj)

def p_request_issues(ris)
  quietly do
    dis = ris.first.decision_review.decision_issues
    puts "---- #{ris.count} RequestIssues with #{dis.count} DecisionIssues"
    ris.order(:id).each_with_index do |ri, i|
      p_request_issue(ri, i)
    end.map(&:to_s)
    dis
    puts "^^^^^^^^^^^^^^^^^^^^"
  end
end

def p_request_issue(r, i = 0)
  puts "#{i + 1}. Request #{r.id}: #{[r.closed_status, r.contested_rating_issue_diagnostic_code, r.benefit_type, r.contested_issue_description]}"
  r.decision_issues.order(:id).each_with_index do |di, i2|
    p_decision_issue(di, i2)
  end
end

def p_decision_issue(di, _i = 0)
  puts "    * Decision #{di.id}: #{[di.disposition, di.diagnostic_code, di.caseflow_decision_date, di.description]}"
end

def p_request_issue_update(riu, i = 0)
  puts "#{i + 1}. RequestIssueUpdate #{riu.id}: #{[riu.review_id, riu.before_request_issue_ids, riu.after_request_issue_ids, riu.processed_at]}"
end

## === ClaimReview ===============================

def claim_review(id)
  if uuid?(id)
    return [HigherLevelReview, SupplementalClaim].each do |clazz|
      r = clazz.find_by(uuid: id)
      return r if r
    end
  end

  # if id is a claim ID
  [HigherLevelReview, SupplementalClaim].each do |clazz|
    epe = EndProductEstablishment.find_by(reference_id: id, source_type: clazz.to_s)
    return epe.source if epe
  end
end

def p_claim_review(cr)
  puts cr.inspect
  puts cr.establishment_error
  puts "Intake completed at: " + cr.establishment_submitted_at
end

## === EndProductEstablishment ===================

def p_epe(epe)
  output = ""
  output << "=== #{epe.id} ==="
  src = epe.source
  output << "    > #{src.class.name} #{src.id}"
  output << "    > empty decision issues? #{src.decision_issues.empty?} ?? true"
  output << "    > has #{src.end_product_establishments.count} epes"
  src.end_product_establishments.each do |e|
    output << "    >> epe #{e.id}, request_issues.count: #{e.request_issues.count}, synced_status: #{e.synced_status} ?? CLR, last_synced_at: #{e.last_synced_at}"
    e.request_issues.each do |ri|
      output << "    >>> ri.contention_disposition.nil? #{ri.contention_disposition.nil?} ?? true"
    end
  end
  puts output.join('\n')
end

## === SQL helpers ==============================

#### Postgres
# query = "SELECT 'ok' AS FIRST_COL, 'b' AS SEC_COL from APPEALS LIMIT 10"
def exec_query(query, conn = ActiveRecord::Base.connection)
  res = conn.exec_query(query)
  puts res.rows.map { |r| r.map(&:inspect).join(",") }.join('\n')
  res.to_a
end

def sql_to_csv(query, raw_conn = ActiveRecord::Base.connection.raw_connection)
  output = []
  raw_conn.copy_data("COPY (#{query.chomp(';')}) TO STDOUT WITH (FORMAT CSV, HEADER TRUE);") do
    while row = raw_conn.get_copy_data
      output << row
    end
  end
  output
end

#### Oracle
# sql = "SELECT 'ok' first_col, 'b' sec_col from BRIEFF where ROWNUM < 10"
def oracle_sql_results(sql, conn = VACOLS::Case.connection)
  result = conn.execute(sql)
  output = []
  while r = result.fetch_hash
    output << r
  end
  output
end

def oracle_sql_to_csv(sql, conn = VACOLS::Case.connection)
  result = conn.execute(sql)
  output = [result.column_metadata.map(&:name).join(",")]
  while r = result.fetch_hash
    output << r.values.join(",")
  end
  output
end

## === Start Pry =================================

# if $LOADED_FEATURES.grep(/pry/).empty?
if !defined?(pry_instance)
  # puts "local_variables", local_variables
  # puts "global_variables", global_variables
  puts "Starting a Pry session"
  require "pry"
  configure_pry
  pry
else
  configure_pry unless $PRY_CONFIGURED
end
