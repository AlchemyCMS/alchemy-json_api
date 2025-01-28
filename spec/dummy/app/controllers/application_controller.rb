# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Necessary for authorize_user stub in controller specs
  def current_user
  end
end
