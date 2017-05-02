require "mime/types"
require "tempfile"

module DSNode
  class Resource < ActiveRecord::Base
    class UnrecognizedFileType < StandardError; end

    self.primary_key = :resourcesid
    self.inheritance_column = :subclass
   
    attr_accessor :new_file, :mime_type, :extension

    before_save :save_to_disk, :if => :new_file
    before_destroy :delete_file

    def file= file
      # normalize when file is an HttpUploadedFile
      self.original_file_name ||= actual_file_name(file)
      file = actual_file(file)

      # queue for after_save hook
      self.new_file = file

      # initial processing
      set_mime_type
      set_type
      set_extension
      set_dimensions_and_duration

      self.file = to_thumbnail_file if needs_processing? # reenter if needed
    end

    def file_path
      File.join "/assets", path, file_name
    end

    def full_path
      File.join "public", file_path
    end

    def url
      file_path
    end
   
    def image?
      media_type == "i"
    end

    def video?
      media_type == "v"
    end

    def audio?
      media_type == "a"
    end

    def pdf?
      media_type == "p"
    end

    def needs_processing?
      false
    end

    def preferred_format
      "jpg"
    end

    def to_thumbnail_file
      result = Tempfile.new(["result", ".#{preferred_format}"])
      if video?
        Dir.mktmpdir do |dir|
          Dir.chdir dir do
            `mplayer -nosound -ss 1 -vf screenshot -frames 1 -vo png:z=9 #{new_file.path} 2>&1`
            `convert 00000001.png -resize #{resize_geometry} 00000001.jpg 2>&1`
            `mv 00000001.jpg #{result.path} 2>&1`
          end
        end
      else
        `convert #{new_file.path}[0] -resize #{resize_geometry} #{result.path} 2>&1`
      end
      result
    end

    private

    def permitted_image_format?
      permitted_image_formats = %w(png jpeg)
      permitted_image_formats.include?(self.extension)
    end

    def set_mime_type
      mime_type_array = `file -ibL "#{new_file.path}"`.chomp.split("; ")
      self.mime_type = MIME::Type.new(mime_type_array)
    end

    def set_type
      type_letter = case mime_type.raw_media_type
      when "video" then "v"
      when "image" then "i"
      when "audio" then "a"
      else
        mime_type == "application/pdf" ? "p" : "d"
      end
      self.media_type= type_letter
    end

    def set_extension
      self.extension = mime_type.sub_type
    end

    def set_dimensions_and_duration
      if video?
        video_metadata = `mplayer -vo null -ao null -frames 0 -identify #{new_file.path} 2>&1`
        self.width = video_metadata[/ID_VIDEO_WIDTH=(\d+)/].split("=").last
        self.height = video_metadata[/ID_VIDEO_HEIGHT=(\d+)/].split("=").last
        self.duration = video_metadata[/ID_LENGTH=([0-9.]+)/].split("=").last
      elsif image?
        command = "identify -format '%w %h' #{new_file.path} 2>&1"
        dimensions = `#{command}`.split(" ")
        self.width, self.height = dimensions
      end
      raise UnrecognizedFileType unless $?.success?
    end

    def save_to_disk
      copy_file
      self.new_file.close if new_file.respond_to?(:close) # otherwise we'll eventually get a Errno::EMFILE
      self.new_file = nil
    end

    def copy_file
      self.file_name = "#{SecureRandom.uuid}.#{extension}"
      folder = File.join("public/assets", path)
      FileUtils.mkdir_p folder
      FileUtils.cp new_file.path, full_path unless new_file.path == full_path
      File.chmod 0644, full_path

      self.md5hash = `md5sum --binary #{full_path}`.split(" ").first
    end

    def delete_file
      FileUtils.rm full_path rescue Errno::ENOENT

      directory = File.join("public/assets/resources", path)
      FileUtils.rmdir directory rescue Errno::ENOTEMPTY
    end

    def actual_file_name file
      if file.respond_to?(:tempfile)
        file.original_filename
      else
        File.basename(file.path)
      end
    end

    def actual_file file
      if file.respond_to?(:tempfile)
        file.tempfile
      else
        file
      end
    end

    # TODO: remove when schema sucks less

    {
      :media_type => :resourcestype,
      :duration => :resourcesduration,
      :width => :resourceswidth,
      :height => :resourcesheight,
      :file_name => :resourcesfilename,
      :original_file_name => :resourcesoriginalfilename,
      :path => :resourcespath,
      :md5hash => :resourceshash,
    }.each do |new_column, old_column|
      alias_attribute new_column, old_column
    end
  end
end

