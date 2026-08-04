trigger ServiceAppointmentTrigger on ServiceAppointment (
    after update
) {
    new MetadataTriggerHandler().run();
}