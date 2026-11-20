# frozen_string_literal: true

class DmcasController < ApplicationController
  def show
    authorize nil, policy_class: DmcaPolicy
  end

  def create
    raise ActionController::BadRequest, "dmca parameter is required" if params[:dmca].blank?

    @dmca = params[:dmca].slice(:name, :email, :address, :infringing_urls, :original_urls, :proof, :perjury_agree, :good_faith_agree, :signature)
    authorize @dmca, policy_class: DmcaPolicy

    Dmail.create_automated(to: User.owner, title: "DMCA Complaint from #{@dmca[:name]}", body: <<~EOS)
      Name: #{@dmca[:name]}
      Email: #{@dmca[:email]}
      Address: #{@dmca[:address]}

      Infringing URLs:
      #{@dmca[:infringing_urls].to_s.split.map { |url| "* #{url}" }.join("\n")}

      Original URLs:
      #{@dmca[:original_urls].to_s.split.map { |url| "* #{url}" }.join("\n")}

      Proof: #{@dmca[:proof]}
      Signature: #{@dmca[:signature]}
    EOS

    UserMailer.with_request(request, dmca: @dmca).dmca_complaint(to: Danbooru.config.dmca_email).deliver_now
    email_address = Danbooru::EmailAddress.parse(@dmca[:email])
    UserMailer.with_request(request, dmca: @dmca).dmca_complaint(to: @dmca[:email]).deliver_now if email_address.present? && !email_address.undeliverable?
  end

  def template
    authorize nil, policy_class: DmcaPolicy
  end
end
