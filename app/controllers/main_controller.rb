
class MainController < ApplicationController

	def default

		redirect_to 'http://www.claco.com'

	end

	def test

		#@time = Time.now.to_f - SERVER_BOOT_TIME.to_f
		@time = Time.now.to_i - SERVER_BOOT_TIME.to_i
		#@seconds = "%.3f"%(@time%60) 
		@seconds = @time.to_i%60
		#@time = @time.to_i
		@minutes = (@time%3600-@seconds.to_i)/60 
		@hours = (@time%86400-@minutes-@seconds.to_i)/3600 
		@days = (@time-@hours-@minutes-@seconds.to_i)/86400 
		
		render 'main/status'

		# respond_to do |format|
		# 	format.html { render :text => 'I love you!' }
		# end

	end

	def time

		#@time = Time.now.to_f - SERVER_BOOT_TIME.to_f
		@time = Time.now.to_i - SERVER_BOOT_TIME.to_i
		#@seconds = "%.3f"%(@time%60) 
		#@time = @time.to_i
		@seconds = @time.to_i%60
		@minutes = (@time%3600-@seconds.to_i)/60 
		@hours = (@time%86400-@minutes-@seconds.to_i)/3600 
		@days = (@time-@hours-@minutes-@seconds.to_i)/86400 

		respond_to do |format|
			format.html {render :text => "#{@days} days, #{@hours} hours, #{@minutes} minutes, #{@seconds} seconds" }
		end

	end

	def tasks

		respond_to do |format|
			format.html {render :text => "Tasks in database: #{Task.all.size.to_s}<br />Scheduled tasks: #{Task.where(:status=>1).size.to_s}<br />Completed tasks: #{Task.where(:status=>2).size.to_s}<br />Failed tasks: #{Task.where(:status=>3).size.to_s}" }
		end

	end

	def routing

		#Task.delay(run_at: 10.seconds.from_now).test
		errors = []

		if !params[:storedir] || !params[:class] || !params[:url] || !params[:model] || !params[:datahash]
			errors << 'Invalid parameter set'
		elsif Digest::MD5.hexdigest(params[:storedir].to_s + params[:class].to_s + params[:url].to_s + params[:model].to_s + RX_PRIVATE_KEY).to_s != params[:datahash].to_s
			errors << 'Invalid key'
		end

		if errors.any?
			respond_to do |format|
				format.json { render :text => MultiJson.encode({ :status => 0, :errors => errors }) }
			end
		else
			task = Task.new

			task.update_attributes(:storedir => params[:storedir].to_s,
									:params => params)

			if params[:origin]=="true"
				Task.delay.processing(task.id.to_s,params[:class],params[:url],params[:model],STAGINGSERVER_API_URL)
			else
				Task.delay.processing(task.id.to_s,params[:class],params[:url],params[:model],APPSERVER_API_URL)
			end

			task.update_attributes(:status => 1)

			respond_to do |format|
				#format.html {render :text => "PARAMS: #{params.to_s}, taskid: #{task.id.to_s}" }
				format.json { render :text => MultiJson.encode({ :status => 1 }) }
			end
		end
	end
end
