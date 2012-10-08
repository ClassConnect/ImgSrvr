
class MainController < ApplicationController

	def default

		redirect_to 'http://www.claco.com'

	end

	def test

		@time = Time.now.to_f - SERVER_BOOT_TIME.to_f
		@seconds = "%.3f"%(@time%60) 
		@time = @time.to_i
		@minutes = (@time%3600-@seconds.to_i)/60 
		@hours = (@time%86400-@minutes-@seconds.to_i)/3600 
		@days = (@time-@hours-@minutes-@seconds.to_i)/86400 
		
		render 'main/status'

		# respond_to do |format|
		# 	format.html { render :text => 'I love you!' }
		# end

	end

	def routing

		#Task.delay(run_at: 10.seconds.from_now).test
		errors = []

		debugger

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

			task.update_attributes(:storedir => params[:storedir].to_s)

			if params[:origin]==true
				Task.delay.processing(task.id.to_s,params[:class],params[:url],params[:model],STAGINGSERVER_API_URL)
			else
				Task.delay.processing(task.id.to_s,params[:class],params[:url],params[:model],APPSERVER_API_URL)
			end

			respond_to do |format|
				#format.html {render :text => "PARAMS: #{params.to_s}, taskid: #{task.id.to_s}" }
				format.json { render :text => MultiJson.encode({ :status => 1 }) }
			end
		end
	end
end
