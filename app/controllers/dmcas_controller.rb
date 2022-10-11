# frozen_string_literal: true

class DmcasController < ApplicationController
  def create
    @dmca = params[:dmca].slice(:name, :email, :address, :infringing_urls, :original_urls, :proof, :perjury_agree, :good_faith_agree, :signature)
    UserMailer.with_request(request, dmca: @dmca).dmca_complaint(to: Danbooru.config.dmca_email).deliver_now
    UserMailer.with_request(request, dmca: @dmca).dmca_complaint(to: @dmca[:email]).deliver_now
  end

  def show
  end

  def template
  end
end
