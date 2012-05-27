module V1
  module Outsourced
    class JobsController < ActionController::Base
      include ::Outsourced::ApplicationControllerMethods
      oauthenticate :interactive => false
      before_filter :ensure_valid_worker
      before_filter :find_job, :only => [:update, :destroy, :attachment, :show]
      after_filter :run_maintenance

      def next
        @job = @worker.reserve_next_job!
        if @job
          respond_to do |format|
            format.json { render :text => @job.to_json }
          end
        else
          head :not_found
        end
      end

      def show
        if @job.payload? && @job.payload.exists?
          send_file @job.payload.path, :filename => File.basename(@job.payload.path), :content_type => @job.payload.content_type
        else
          head :not_found
        end
      end

      def create
        @job = ::Outsourced::Job.new(params[:job])
        if @job.save!
          render :text => @job.to_json
        else
          raise @job.errors.full_messages.join(", ")
        end
      end

      def update
        @job.update_attributes(params[:job])
        head :ok
      end

      def destroy
        @job.finished!
        head :ok
      end

      protected

      def current_user=(worker)
        @worker = worker
      end

      private

      def run_maintenance
        ::Outsourced::Maintenance.new.perform
      end

      def ensure_valid_worker
        unless @worker && @worker.active?
          access_denied
        end
      end

      def find_job
        @job = @worker.outsourced_jobs.find(params[:id])
        unless @job
          head(:not_found)
          return false
        end
      end
    end
  end
end