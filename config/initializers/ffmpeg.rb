unless Rails.env.development?
  FFMPEG.logger.level = Logger::ERROR
end
