
puts "(Loading .pryrc)"

# require 'rubygems'
# require 'wirble'
# Wirble.init
# Wirble.colorize

#TaskTreeRender.treeconfig[:default_atts] = [:id, :status, :updated_at, :assigned_to_type, :ASGN_TO]
#TaskTreeRender.treeconfig[:heading_fill_char] = ". "
#puts "TaskTreeRender customized"

Pry.config.hooks.add_hook(:before_session, :rails) do
  if defined?(Rails)
     # rails commands

     def sql(turn_on=nil)
       if turn_on
     	   ActiveRecord::Base.logger.level = 0
       else
     	   ActiveRecord::Base.logger.level = 1
       end
     end

     sql

  end
end

def tree1(obj, *atts, **kwargs)
  kwargs[:renderer] ||= TaskTreeRenderModule.new_renderer
  kwargs[:renderer].tap do |r|
    r.compact
    r.config.default_atts = [:id, :status, :ASGN_TO, :UPD_DATE]
  end
  obj.treee(*atts, **kwargs)
end

def tree2(obj, *atts, **kwargs)
  kwargs.delete(:renderer) && fail("Use other approach to allow 'renderer' named parameter!")
  renderer = TaskTreeRenderModule.new_renderer.tap do |r|
    r.compact
    r.config.default_atts = [:id, :status, :ASGN_TO, :UPD_DATE]
  end
  puts renderer.tree_str(obj, *atts, **kwargs)
end

# Log to STDOUT if in Rails
if ENV.include?('RAILS_ENV') && !Object.const_defined?('RAILS_DEFAULT_LOGGER')
  require 'logger'
  RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)
end

alias e exit

# Easily print methods local to an object's class
# Appeal.find(1).local_methods
class Object
  def local_methods
    (methods - Object.instance_methods).sort
  end
end

# ==================================================

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

# ==================================================

# col_labels = { date: "Date", from: "From", subject: "Subject" }
# arr = [{date: "2014-12-01", from: "Ferdous", subject: "Homework this week"},
#        {date: "2014-12-01", from: "Dajana", subject: "Keep on coding! :)"},
#        {date: "2014-12-02", from: "Ariane", subject: "Re: Homework this week"}]
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
               width: [arr.map { |g| g[col].size }.max, label.size].max
             }
  end
end
def write_line(columns, h, col_sep="|")
  str = h.keys.map { |k|
    "#{h[k].ljust(columns[k][:width])}"
  }.join(" #{col_sep} ")
  "| #{str} |"
end
def write_header(columns, col_sep="|")
  "| #{ columns.map { |_,g| g[:label].ljust(g[:width]) }.join(" #{col_sep} ") } |"
end
def write_divider(columns, col_sep="+|+")
  "#{col_sep[0]}-#{ columns.map { |_,g| "-"*g[:width] }.join("-#{col_sep[1]}-") }-#{col_sep[2]}"
end

# ==================================================

def m(obj, *args)
  return tmm_Task(obj, *args) if obj.is_a? Task

  begin
    send("tmm_#{obj.class.name}", obj, *args)
  rescue NoMethodError
    pp obj
  end
end

def tmm_Task(obj, atts=[:id, :parent_id, :type, :status, :assigned_to_type, :assigned_at])
  atts.unshift(" ")
  col_labels=atts.map{|f| {f => f&.to_s}}.reduce({}, :merge)
  arr=build_cells_from([obj.parent, obj, *obj.children], atts, obj)
  #pp arr
  print_table(col_labels, arr)
  tmm_Appeal(obj.appeal) if obj.appeal
  obj
end
def build_cells_from(tasklist, atts, highlight_obj=nil)
  tasklist.compact.map{|row_obj|
    atts.map{|f|
      { f => row_obj.respond_to?(f) ? "#{row_obj.send f}" : "" }
    }.reduce({}, :merge).tap { |hash|
      hash[" "]="*" if row_obj==highlight_obj
    }
  }
end
def tmm_Appeal(obj)
  #puts obj.structure_render(:id, :assigned_to_type, :status, :parent_id, :assigned_to_id, :created_at, :updated_at)
  puts structure_render(obj, :id, :assigned_to_type, :status, :parent_id, :assigned_to_id, :created_at, :updated_at)
  obj
end

# ==================================================

class Hash
  def depth
    arr = values
    d = 1
    loop do
      arr = arr.flatten.select { |e| e.is_a? Hash }
      break d if arr.empty?
      d += 1
      arr = arr.map(&:values)
    end
  end
end
