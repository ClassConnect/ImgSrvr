# encoding: utf-8

# require 'carrierwave/processing/mini_magick'

class AvatarUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  #include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :fog

  # version :thumb_xlg do
  #   process resize_to_fill: [AVATAR_XLDIM,AVATAR_XLDIM]
  #   process :convert => "png"
  #   def full_filename(for_file = model.avatar.file)
  #     "thumb_xlg.png"
  #   end
  # end

  # version :thumb_lg do
  #   process resize_to_fill: [AVATAR_LDIM,AVATAR_LDIM]
  #   process :convert => "png"
  #   def full_filename(for_file = model.avatar.file)
  #     "thumb_lg.png"
  #   end
  # end

  # version :thumb_mg do
  #   process resize_to_fill: [AVATAR_MGDIM,AVATAR_MGDIM]
  #   process :convert => "png"
  #   def full_filename(for_file = model.avatar.file)
  #     "thumb_mg.png"
  #   end
  # end

  # version :thumb_md, :from_version => :thumb_lg do
  #   process resize_to_fill: [AVATAR_MDIM,AVATAR_MDIM]
  #   process :convert => "png"
  #   def full_filename(for_file = model.avatar.file)
  #     "thumb_md.png"
  #   end
  # end

  # version :thumb_sm, :from_version => :thumb_md do
  #   process resize_to_fill: [AVATAR_SDIM,AVATAR_SDIM]
  #   process :convert => "png"
  #   def full_filename(for_file = model.avatar.file)
  #     "thumb_sm.png"
  #   end
  # end


  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    #Digest::MD5.hexdigest(model.teacher.id.to_s + model.size.to_s + model.data.to_s)
    model.storedir
  end

  # def default_url
  #   asset_path "placer.png"
  # end

  def fog_directory
    # if Rails.env == "production"
      "img.cla.co"
    # else
      # "rich.cla.co"
    # end
  end

  def fog_public
    true
  end

  def fog_host
    # if Rails.env == "production"
      "http://img.cla.co"
    # else
      # "http://rich.cla.co"
    # end
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end


end
