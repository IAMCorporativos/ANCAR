class Supervisor::BaseController < ApplicationController
  include SupervisorActions
  layout 'admin'

  private

    def verify_supervisor
      raise CanCan::AccessDenied unless (current_user.has_role? :supervisor) || (current_user.has_role? :admin)
    end
end
