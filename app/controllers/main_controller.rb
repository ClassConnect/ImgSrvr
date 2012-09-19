
class MainController < ApplicationController

	def default

		redirect_to 'http://www.claco.com'

	end

	def test

		respond_to do |format|
			format.html { render :text => 'hello!' }
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

			task.update_attributes(:storedir => params[:storedir].to_s)

			Task.delay.processing(task.id.to_s,params[:class],params[:url],params[:model])

			respond_to do |format|
				#format.html {render :text => "PARAMS: #{params.to_s}, taskid: #{task.id.to_s}" }
				format.html { render :text => MultiJson.encode({ :status => 1 }) }
			end
		end
	end
end
