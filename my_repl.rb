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

def _set_pry_prompt
  puts "    Configuring Pry.config.prompt"
  Pry.config.prompt = [
    proc { |target_self, nest_level, pry|
          "[#{pry.input_ring.size}] \001\e[0;35m\002#{Pry.config.prompt_name}"+
          "\001\e[0m\002(\001\e[0;33m\002#{Pry.view_clip(target_self)}"+
          "\001\e[0m\002)#{":#{nest_level}" unless nest_level.zero?}> "
         },
    proc { |target_self, nest_level, pry|
          "[#{pry.input_ring.size}] \001\e[1;32m\002#{Pry.config.prompt_name}"+
          "\001\e[0m\002(\001\e[1;33m\002#{Pry.view_clip(target_self)}"+
          "\001\e[0m\002)#{":#{nest_level}" unless nest_level.zero?}*   "
         }
    ]
end

def tiny_prompt
  sql_off
  tiny_prompt=proc { "\001\e[0;35m\002> \001\e[0m\002" }
  pry({ prompt: tiny_prompt })
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
  $PRY_CONFIGURED=true
end

## === Introspection ===========================

# print methods local to an object's class
# someobj.local_methods
def local_methods(obj=self)
  (obj.methods - Object.instance_methods).sort
end

def obj_inst_methods(obj=self)
  clazz = obj.is_a?(Class) ? obj : obj.class
  clazz.instance_methods(false).sort
end
def public_methods_without_parent(obj=self)
  (obj.public_methods - obj.class.superclass.methods).sort
end

IGNORED_PREFIXES = %w"_ before_ after_ autosave_"
# ignore_prefixes(obj_inst_methods(obj))
# ignore_prefixes(methods_without_parent(obj))
def ignore_prefixes(methods)
  methods.reject{|m|
    IGNORED_PREFIXES.any?{|prefix| m.to_s.start_with?(prefix)}
  }
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
    cells = objects.map{ |o| o.send(method_name).inspect }
    cells.unshift(method_name)

    puts cells.map{ |cell| cell.to_s.ljust(col_width) }.join ' '
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
  col_labels.each_with_object({}) do |(col,label),h|
    h[col] = { label: label,
               width: [arr.map { |g| g[col].to_s.size }.max, label.size].max
             }
  end
end
def write_line(columns, h, col_sep="|")
  str = columns.keys.map { |k|
    "#{h.send(k).to_s.ljust(columns[k][:width])}"
  }.join(" #{col_sep} ")
  "| #{str} |"
end
def write_header(columns, col_sep="|")
  "| #{ columns.map { |_,g| g[:label].ljust(g[:width]) }.join(" #{col_sep} ") } |"
end
def write_divider(columns, col_sep="+|+")
  "#{col_sep[0]}-#{ columns.map { |_,g| "-"*g[:width] }.join("-#{col_sep[1]}-") }-#{col_sep[2]}"
end
# -------------------------------


## === TaskTreeRender ===========================

treee = {
  renderer: TaskTreeRenderModule.global_renderer,
  attrs: TaskTreeRenderModule.global_renderer.config.default_atts,
  config: TaskTreeRenderModule.global_renderer.config
}

def treee_compact
  TaskTreeRenderModule.global_renderer.compact_mode
end

def treee_attrs(*atts)
  TaskTreeRenderModule.global_renderer.config.tap do |conf|
    conf.default_atts = atts
  end
end

def treee_add_attrs(*atts)
  treee_attrs(treee.attrs + atts)
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

# Suppress SQL queries to reduce console clutter
$NESTED_QUIETLY=0
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

## === Person ====================================

def p_vet(id)
  vet=Veteran.find_by_file_number_or_ssn(id)

  crs=ClaimReview.find_all_visible_by_file_number(vet.file_number)
  crs.each{|cr| p_claim_review(cr)}

  appeals=AppealFinder.find_appeals_with_file_numbers(vet.file_number)
  appeals.each{|a| p_appeal(a)}

  vet
end

# user 3
# user "BvaAAbshire"
# user 'ABS'
def user(id)
  user=User.find(id) if id.is_a? Numeric
  return user if user

  user=User.find_by(css_id: id.upcase) if id.is_a? String
  return user if user

  staff=VACOLS::Staff.find_by(slogid: id.upcase)
  return User.find_by(css_id: staff.sdomainid) if staff

  users = User.where("UPPER(full_name) LIKE ?", "%#{id.upcase}%")
  return users.first if users.count==1
  puts "Found #{users.count} users with full_name like %#{id.upcase}%: #{users.map{|u| [u.css_id, u.full_name]}}"
end

def staff(id)
	return VACOLS:Staff.find_by(sdomainid: id.css_id) if id.is_a? User

	staff=VACOLS::Staff.find_by(slogid: id.upcase)
	return staff if staff

	staff=VACOLS::Staff.find_by(sdomainid: id.upcase)
	return staff if staff
end

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
    user
  end
end

# Need to access external systems
RequestStore[:current_user] = User.system_user

# authenticate user
def auth_user(user)
  RequestStore[:current_user]=user
  # https://github.com/department-of-veterans-affairs/caseflow/wiki/Debugging-Tips#authenticating-in-the-rails-console
  User.authentication_service.user_session = User.authentication_service.get_user_session(user.id)
end

## === Appeal ====================================

# appeal "1c11a1ae-43bd-449b-9416-7ccb9cb06c11"
# appeal 1234567
def appeal(obj)
  appeal = obj if obj.is_a?(Appeal) || obj.is_a?(LegacyAppeal)
  appeal = uuid?(obj) ? Appeal.find_by(uuid: obj) : LegacyAppeal.find_by(vacols_id: obj) if appeal.nil?
end

# p_appeal appeal "f3c20696-9c28-4213-bcc3-cba93b6e6184"
def p_appeal(appeal)
  quietly do
    appeal.treee

    p_legacy_appeal(appeal) if appeal.is_a?(LegacyAppeal)

    AttorneyCaseReview.find_by(task_id: appeal.tasks.pluck(:id)).tap {|acr| puts acr&.inspect }

    JudgeCaseReview.find_by(task_id: appeal.tasks.pluck(:id)).tap {|jcr| puts "  #{jcr&.inspect}"}

    puts "---- #{appeal.hearings.count} Hearings"
    appeal.hearings.each{|hearing|
      p_hearing(hearing)
    } if defined? p_hearing

    ris=appeal.issues
    ris=ris[:request_issues] if appeal.is_a?(Appeal)
    puts "---- #{ris.count} Request Issue(s)"
    p_request_issues(ris) if defined? p_request_issues

    rius = RequestIssuesUpdate.where(review: appeal)
    puts "---- #{rius.count} Request Issues Update(s)"
    rius.each_with_index{|riu,i|
      p_request_issue_update(riu,i)
    } if defined? p_request_issue_update

    if appeal.is_a?(LegacyAppeal)
      decs=appeal.decisions
      puts "---- #{decs.count} Decision(s)"
      decs.each{|doc| puts "  #{doc&.inspect}"}
    end

    appeal
  end
end

# p_appeal appeal 3085659
def p_legacy_appeal(appeal)
  quietly do
    tasks=LegacyWorkQueue.tasks_by_appeal_id(appeal.vacols_id)
    puts "____________________"
    puts "---- Legacy Tasks"
    tasks.map do |t|
      puts "#{t.class.name}, assigned_by: #{t.assigned_by&.inspect} #{t.assigned_by&.sdomainid}, assigned_to: #{t.assigned_to&.inspect} #{t.assigned_to&.sdomainid}, at: #{t.assigned_at}\n"
    rescue
      puts "#{t.class.name}, assigned_by: #{t.assigned_by&.inspect}, assigned_to: #{t.assigned_to&.inspect}, at: #{t.assigned_at}\n"
    end

    puts "---- Prior Locations"
    puts "changed_at, change_to, changed_by, prior_loc"
    pp appeal.location_history.pluck(:locdout, :locstto, :locstrcv, :locstout)
    puts "^^^^^^^^^^^^^^^^^^^^"
    tasks
  end
end

## === Legacy appeal =============================

def legacies(vet)
  LegacyAppeal.fetch_appeals_by_file_number(vet.file_number).tap{|las|
    las.map{|l|
      { nod: l.nod_date, soc: l.soc_date, ssoc: l.ssoc_dates,
        vacols_id: l.vacols_id, disposition: l.disposition
      }
    }
  }
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

def hearing(id)
  Hearing.find_hearing_by_uuid_or_vacols_id(id)
end

# p_appeal appeal "3ee973ab-467e-46c6-9b0b-7c83e11ecd6c"
# p_hearing hearing "cbdde413-1461-4a64-a82e-06e8df147c2c"
def p_hearing(hearing)
  quietly do
    puts hearing.inspect
    puts "    Day:#{[hearing.hearing_day.scheduled_for, hearing.hearing_day.request_type, hearing.hearing_day.regional_office]}, "+
      "Judge:#{[hearing.judge.css_id, hearing.judge.full_name]}" if hearing.hearing_day

    p_legacy_hearing(hearing) if hearing.is_a? LegacyHearing
  end
end

def p_legacy_hearing(hearing)
  puts "TBD"
end

## === RequestIssue ================================

def p_request_issues(ris)
  quietly do
    dis=ris.first.decision_review.decision_issues
    puts "---- #{ris.count} RequestIssues with #{dis.count} DecisionIssues"
    ris.order(:id).each_with_index{|ri,i|
      p_request_issue(ri, i)
    }.map(&:to_s)
    dis
    puts "^^^^^^^^^^^^^^^^^^^^"
  end
end

def p_request_issue(r, i=0)
  puts "#{i+1}. Request #{r.id}: #{[r.closed_status, r.contested_rating_issue_diagnostic_code, r.benefit_type, r.contested_issue_description].to_s}"
  r.decision_issues.order(:id).each_with_index{|di,i2|
    p_decision_issue(di,i2)
  }
end

def p_decision_issue(di, i=0)
  puts "    * Decision #{di.id}: #{[di.disposition, di.diagnostic_code, di.caseflow_decision_date, di.description]}"
end

def p_request_issue_update(riu,i=0)
  puts "#{i+1}. RequestIssueUpdate #{riu.id}: #{[riu.review_id, riu.before_request_issue_ids, riu.after_request_issue_ids, riu.processed_at].to_s}"
end

## === ClaimReview ===============================

def claim_review(id)
  return [HigherLevelReview, SupplementalClaim].each{|clazz|
    r=clazz.find_by(uuid: id)
    return r if r
  } if uuid?(id)

  # if id is a claim ID
  return [HigherLevelReview, SupplementalClaim].each{|clazz|
    epe=EndProductEstablishment.find_by(reference_id: id, source_type: clazz.to_s)
    return epe.source if epe
  }
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

def sql_to_csv(raw_conn, sql)
  output = []
  raw_conn.copy_data("COPY (#{sql.chomp(';')}) TO STDOUT WITH (FORMAT CSV, HEADER TRUE);") do
    while row = raw_conn.get_copy_data
      output << row
    end
  end
  output
end

def oracle_sql_to_csv(conn, sql)
  output = []
  result = conn.execute(sql)
  while r = result.fetch_hash
    output << r.values.join(',')
  end
  output
end

## === Start Pry =================================

# if $LOADED_FEATURES.grep(/pry/).empty?
if not defined?(Pry)
  # puts "local_variables", local_variables
  # puts "global_variables", global_variables
  puts "Starting a Pry session"
  require 'pry'
  configure_pry
  pry
else
  configure_pry unless $PRY_CONFIGURED
end
