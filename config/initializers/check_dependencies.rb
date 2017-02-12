%w(mplayer identify).each do |dep|
  raise "External dependency *#{dep}* not found! Please install." unless `which #{dep}` and $?.success?
end
