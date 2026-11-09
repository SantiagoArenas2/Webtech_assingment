class ApplicationNotificationsMailer < ApplicationMailer
  def new_application(application)
    @application = application
    @room = application.room
    mail(to: @room.property.host.email, subject: "New application for #{@room.label}")
  end
end
