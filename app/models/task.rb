class Task
	include Mongoid::Document

	class FilelessIO < StringIO
		attr_accessor :original_filename

		def set_filename(name = "")
			@original_filename = name
			return self
		end
	end

	field :storedir, :type => String

	# 0 - not scheduled, not completed
	# 1 - scheduled, not completed
	# 2 - completed
	# 3 - error
	field :status, :type => Integer, :default => 0

	field :params, :type => Hash, :default => {}

	mount_uploader :img_contentview, ImageUploader
	mount_uploader :img_thumb_lg, ImageUploader
	mount_uploader :img_thumb_sm, ImageUploader
	mount_uploader :avatar_thumb_lg, AvatarUploader
	mount_uploader :avatar_thumb_mg, AvatarUploader
	mount_uploader :avatar_thumb_md, AvatarUploader
	mount_uploader :avatar_thumb_sm, AvatarUploader


	# def self.test

	# 	a = Task.new

	# 	a.update_attributes(:test => 'fuck you')

	# end

	def self.delayed_delete(id)

		Task.find(id).delete

	end

	def self.processing(taskid,imgclass,url,model,destination)

		task = Task.find(taskid.to_s)

		case imgclass
		when 'avatar'

			#

			origimg = Magick::ImageList.new

			open(URI::encode(url)) do |f|
				origimg.from_blob(f.read)
			end

			origimg.format = BLOB_FILETYPE

			task.update_attributes( :avatar_thumb_lg => FilelessIO.new(origimg.resize_to_fill!(AVATAR_LDIM, AVATAR_LDIM ).to_blob).set_filename("thumb_lg.png"))
			task.update_attributes( :avatar_thumb_mg => FilelessIO.new(origimg.resize_to_fill!(AVATAR_MGDIM,AVATAR_MGDIM).to_blob).set_filename("thumb_mg.png"))
			task.update_attributes( :avatar_thumb_md => FilelessIO.new(origimg.resize_to_fill!(AVATAR_MDIM, AVATAR_MDIM ).to_blob).set_filename("thumb_md.png"))
			task.update_attributes( :avatar_thumb_sm => FilelessIO.new(origimg.resize_to_fill!(AVATAR_SDIM, AVATAR_SDIM ).to_blob).set_filename("thumb_sm.png"))
	
			origimg.destroy!

			GC.start

			modelarr = ['teacher',model[0]]

			thumbarr = [task.avatar_thumb_lg.url.to_s,
						task.avatar_thumb_mg.url.to_s,
						task.avatar_thumb_md.url.to_s,
						task.avatar_thumb_sm.url.to_s ]
			
		when 'image'

			#TODO: migrate smart thumbnails into here

			origimg = Magick::ImageList.new

			#Rails.logger.debug "after initializing origimg: #{`ps -o rss= -p #{$$}`}"

			# retrieve fullsize image from S3 store, read into an ImageList object
			open(url) do |f|
				origimg.from_blob(f.read)
			end

			#Rails.logger.debug "after reading image from blob: #{`ps -o rss= -p #{$$}`}"

	        origimg.format = BLOB_FILETYPE

			# Wrap filestring as pseudo-IO object, compress if width exceeds 700
			if !(origimg.columns.to_i < CV_WIDTH)

				task.update_attributes(	:img_contentview => FilelessIO.new(origimg.resize_to_fit!(CV_WIDTH,nil).to_blob).set_filename(CV_FILENAME))

				# shrink image to be reasonably processed (this is what the thumb algos will use)
				#origimg.resize_to_fit!(IMGSCALE,IMGSCALE)
			else

				task.update_attributes(	:img_contentview => FilelessIO.new(origimg.to_blob).set_filename(CV_FILENAME))

			end

			GC.start

			task.update_attributes(	:img_thumb_lg => FilelessIO.new(origimg.resize_to_fill!(LTHUMB_W,LTHUMB_H,Magick::CenterGravity).to_blob).set_filename(LTHUMB_FILENAME))

			GC.start

			task.update_attributes(	:img_thumb_sm => FilelessIO.new(origimg.resize_to_fill!(STHUMB_W,STHUMB_H,Magick::CenterGravity).to_blob).set_filename(STHUMB_FILENAME))#,
									#:imgstatus => stathash)

			#Rails.logger.debug "before destroying origimg: #{`ps -o rss= -p #{$$}`}"

			origimg.destroy!

			GC.start

			modelarr = ['binder',model[0],model[1]]

			thumbarr = [task.img_contentview.url.to_s,
						task.img_thumb_lg.url.to_s,
						task.img_thumb_sm.url.to_s ]

		when 'url'

			#

			origimg = Magick::ImageList.new

			# retrieve fullsize image from S3 store, read into an ImageList object
			open(url) do |f|
				origimg.from_blob(f.read)
			end

	        origimg.format = BLOB_FILETYPE

			# Wrap filestring as pseudo-IO object, compress if width exceeds 700
			if !(origimg.columns.to_i < CV_WIDTH)

				task.update_attributes(	:img_contentview => FilelessIO.new(origimg.resize_to_fit!(CV_WIDTH,nil).to_blob).set_filename(CV_FILENAME))

				# shrink image to be reasonably processed (this is what the thumb algos will use)
				#origimg.resize_to_fit!(IMGSCALE,IMGSCALE)
			else

				task.update_attributes(	:img_contentview => FilelessIO.new(origimg.to_blob).set_filename(CV_FILENAME))

			end

			GC.start

			task.update_attributes(	:img_thumb_lg => FilelessIO.new(origimg.resize_to_fill!(LTHUMB_W,LTHUMB_H,Magick::NorthGravity).to_blob).set_filename(LTHUMB_FILENAME))

			GC.start

			task.update_attributes(	:img_thumb_sm => FilelessIO.new(origimg.resize_to_fill!(STHUMB_W,STHUMB_H,Magick::NorthGravity).to_blob).set_filename(STHUMB_FILENAME))#,
									#:imgstatus => stathash)

			origimg.destroy!

			GC.start

			modelarr = ['binder',model[0],model[1]]

			thumbarr = [task.img_contentview.url.to_s,
						task.img_thumb_lg.url.to_s,
						task.img_thumb_sm.url.to_s ]

		when 'video'

			#

			origimg = Magick::ImageList.new

			# retrieve fullsize image from S3 store, read into an ImageList object
			open(url) do |f|
				origimg.from_blob(f.read)
			end

	        origimg.format = BLOB_FILETYPE

			if (origimg.columns.to_i > IMGSCALE || origimg.rows.to_i > IMGSCALE)
				origimg.resize_to_fit!(IMGSCALE,IMGSCALE)
			end

			GC.start

			task.update_attributes(	:img_thumb_lg => FilelessIO.new(origimg.resize_to_fill!(LTHUMB_W,LTHUMB_H,Magick::CenterGravity).to_blob).set_filename(LTHUMB_FILENAME))

			GC.start

			task.update_attributes(	:img_thumb_sm => FilelessIO.new(origimg.resize_to_fill!(STHUMB_W,STHUMB_H,Magick::CenterGravity).to_blob).set_filename(STHUMB_FILENAME))#,
									#:imgstatus => stathash)

			origimg.destroy!

			GC.start

			modelarr = ['binder',model[0],model[1]]

			thumbarr = [  "void",
						task.img_thumb_lg.url.to_s,
						task.img_thumb_sm.url.to_s ]

		# this is also used for smartnotebooks - no additional logic is needed
		when 'croc'

			#

			origimg = Magick::ImageList.new

			open(url) do |f|
				origimg.from_blob(f.read)
			end

	        origimg.format = BLOB_FILETYPE

			if (origimg.columns.to_i > IMGSCALE || origimg.rows.to_i > IMGSCALE)
				origimg.resize_to_fit!(IMGSCALE,IMGSCALE)
			end

			GC.start

			new_img_lg = Magick::ImageList.new
			new_img_lg << Magick::Image.new(LTHUMB_W,LTHUMB_H)
			filled_lg = new_img_lg.first.color_floodfill(1,1,Magick::Pixel.from_color(CROC_BACKGROUND_COLOR))
			filled_lg.composite!(origimg.resize_to_fit(LTHUMB_W-4,LTHUMB_H-4).border(1,1,CROC_BORDER_COLOR),Magick::CenterGravity,Magick::OverCompositeOp)
			filled_lg.format = BLOB_FILETYPE

			task.update_attributes(	:img_thumb_lg => FilelessIO.new(filled_lg.to_blob).set_filename(LTHUMB_FILENAME))

			new_img_lg.destroy!
			filled_lg.destroy!

			GC.start

			new_img_sm = Magick::ImageList.new
			new_img_sm << Magick::Image.new(STHUMB_W,STHUMB_H)
			filled_sm = new_img_sm.first.color_floodfill(1,1,Magick::Pixel.from_color(CROC_BACKGROUND_COLOR))
			filled_sm.composite!(origimg.resize_to_fit(STHUMB_W-4,STHUMB_H-4).border(1,1,CROC_BORDER_COLOR),Magick::CenterGravity,Magick::OverCompositeOp)
			filled_sm.format = BLOB_FILETYPE

			# stathash = task.imgstatus
			# stathash['img_thumb_lg']['generated'] = true
			# stathash['img_thumb_sm']['generated'] = true

			task.update_attributes(	:img_thumb_sm => FilelessIO.new(filled_sm.to_blob).set_filename(STHUMB_FILENAME))#,
									#:imgstatus => stathash)

			new_img_sm.destroy!
			filled_sm.destroy!
			origimg.destroy!

			GC.start

			modelarr = ['binder',model[0],model[1]]

			#thumbs = [  :thumb_lg => task.avatar_thumb_lg.url.to_s,
			#			:thumb_mg => task.avatar_thumb_mg.url.to_s,
			#			:thumb_md => task.avatar_thumb_md.url.to_s,
			#			:thumb_sm => task.avatar_thumb_sm.url.to_s ]

			thumbarr = [  "void",
						task.img_thumb_lg.url.to_s,
						task.img_thumb_sm.url.to_s ]



		end

		datahash = Digest::MD5.hexdigest(thumbarr.to_s + modelarr.to_s + TX_PRIVATE_KEY).to_s

		response = RestClient.post(destination,{ 	:datahash => datahash,
													:model => modelarr,
													:thumbs => thumbarr })

		if response['status']==0
			task.update_attributes(:status => 3)
			raise "Failed! #{response}"
		else
			task.update_attributes(:status => 2)
			Task.delay(run_at: 24.hours.from_now).delayed_delete(task.id.to_s)
		end 

	end
end
