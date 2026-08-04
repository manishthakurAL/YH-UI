import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class CustomConfirmModal extends LightningModal {
    @api confirmMessage;
    @api confirmTitle = 'Please Confirm';
    @api confirmLabel = 'Confirm';
    @api cancelLabel = 'Cancel';

    handleConfirm() {
        this.close(true);
    }

    handleCancel() {
        this.close(false);
    }
}