require 'fileutils'
Dir['images.bak/*.jpg'].each do |file|
  if file.split('/').last.split('.').first.split('_').last.to_i % 3 == 0
    FileUtils.cp file, 'images/'
  end
end
