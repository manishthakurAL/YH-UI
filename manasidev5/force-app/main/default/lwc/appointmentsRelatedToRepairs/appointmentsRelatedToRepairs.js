import { LightningElement, api } from 'lwc';

export default class AppointmentsRelatedToRepairs extends LightningElement {
    @api appointment;
   
    getFormattedDate(dateValue) {
        if (!dateValue) return '-';
        const date = new Date(dateValue);
        return date.toLocaleDateString('en-GB', {
            day: 'numeric',
            month: 'short',
            year: 'numeric'
        });
    }

    get formattedAppointmentDate(){
        return this.getFormattedDate(this.appointment.appointmentDate);

    }
}