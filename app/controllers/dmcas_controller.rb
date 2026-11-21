# frozen_string_literal: true

class DmcasController < ApplicationController
  def show
    @dmca = DmcaRequest.new
    authorize @dmca, policy_class: DmcaPolicy
  end

  def create
    raise ActionController::BadRequest, "dmca parameter is required" if params[:dmca].blank?

    @dmca = DmcaRequest.new(params.slice(:dmca).permit(dmca: %i[name email address infringing_urls original_urls proof signature])[:dmca])
    authorize @dmca, policy_class: DmcaPolicy

    if @dmca.save
      UserMailer.with_request(request, dmca: @dmca).dmca_complaint(to: Danbooru.config.dmca_email).deliver_later
      email_address = Danbooru::EmailAddress.parse(@dmca.email)
      UserMailer.with_request(request, dmca: @dmca).dmca_complaint(to: @dmca.email).deliver_later if email_address.present? && !email_address.undeliverable?
    else
      flash.now[:notice] = @dmca.errors.full_messages.join("; ")
      render :show, status: 422
    end
  end

  def template
    authorize nil, policy_class: DmcaPolicy
  end
end
