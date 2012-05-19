module V1
  module Outsourced
    class JobsController < ActionController::Base
      include ::Outsourced::ApplicationControllerMethods
      oauthenticate :interactive => false
      before_filter :ensure_valid_worker
      before_filter :find_job, :only => [:put, :delete, :attachment]

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

      def attachment
        #TODO send file
      end

      def create
        #TODO create a new job
        #TODO handle attachment
      end

      def update
        #TODO complete
      end

      def destroy
        #TODO fail
      end

      protected

      def current_user=(worker)
        @worker = worker
      end

      private

      def ensure_valid_worker
        unless @worker && @worker.active?
          access_denied
        end
      end

      def find_job
        @worker.outsourced_jobs.find(params[:id])
      end
    end
  end
end