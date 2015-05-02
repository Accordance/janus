require 'logger'
require 'fileutils'

targets = []
log = APP_CONFIG[:log]
log_entries = Array(log[:logger])

log_entries << 'console' if log_entries.empty?
log_entries.each do |entry|
  if entry == 'stdout' || entry == 'console'
    $stdout.sync = true
    targets << STDOUT
  elsif entry == 'null' || entry == 'false' || entry == false
    targets << '/dev/null'
  else
    folder = File.dirname(entry)
    FileUtils.mkdir_p(folder) unless Dir.exist?(folder)
    log_file = File.open(entry, 'a')
    log_file.sync = true
    targets << log_file
  end
end

class MultiLogger
  def initialize(*targets)
    @targets = targets.flatten
  end

  def write(*args)
    @targets.each { |t| t.write(*args) }
  end

  def close
    @targets.each(&:close)
  end
end

target = targets.count == 1 ? targets[0] : MultiLogger.new(targets)
logger = Logger.new target
original_formatter = Logger::Formatter.new
logger.formatter = proc { |severity, datetime, progname, msg|
  original_formatter.call(severity, datetime, progname, msg.dump)
}

APP_LOGGER = logger

SEVERITY = {
  DEBUG: 0,
  INFO: 1,
  WARN: 2,
  ERROR: 3,
  FATAL: 4,
  # UNKNOWN = 5
}
lvl = log[:level].to_s.to_sym
lvl = :ERROR if lvl == :''
puts "Log level: #{lvl}"
APP_LOGGER.level = SEVERITY[lvl]
