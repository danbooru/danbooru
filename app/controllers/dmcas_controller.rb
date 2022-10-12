# frozen_string_literal: true

class DmcasController < ApplicationController
  def create
    @dmca = params[:dmca].slice(:name, :email, :address, :infringing_urls, :original_urls, :proof, :perjury_agree, :good_faith_agree, :signature)

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
    UserMailer.with_request(request, dmca: @dmca).dmca_complaint(to: @dmca[:email]).deliver_now
  end

  def show
  end

  def template
  end
end
