import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getDailyActionRecord from "@salesforce/apex/DailyActionsController.getDailyActionRecord";
import upadteDailyActionRecord from "@salesforce/apex/DailyActionsController.upadteDailyActionRecord";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import SERVICE_RESOURCE_STEPS from '@salesforce/schema/ServiceResourceStep__c';
import READYTOWORKYESNO from "@salesforce/schema/ServiceResourceStep__c.ReadyToWork__c";
import REASONNOVANCHECKCOMPLETED from "@salesforce/schema/ServiceResourceStep__c.ReasonVanCheckCannotBeCompleted__c";


export default class Flowaction extends NavigationMixin(LightningElement) {
readyToWork = false;
firstScreenVisible;
picklistYesNo;
isReadyToWorkNo;
canYouProceedWithSANo;
vehicleCheckVisible;
vanCheckNotCompletedReason;
disableVanCheck;
vanCheckCompletedNo;
disableReadyToWork;
error;
hasError;
dailyActionRecord;
vanCheckCompleted;
canYouProceedWithSA;
readyToWorkValue;
vanCheckNotCompletedReasonValue;
callComments;
isValid;



connectedCallback(event){
    this.disableVanCheck = true;
    this.disableReadyToWork  = true;
    this.fetchDailyActionRecord();
}

fetchDailyActionRecord(){
  getDailyActionRecord()
      .then(data => {
          this.firstScreenVisible = true;
          this.dailyActionRecord = data;
          if(this.dailyActionRecord.ReadyToWork__c != null){
            this.disableReadyToWork =  true;
          }else{
            this.disableReadyToWork = false;
          }
          if(this.dailyActionRecord.VanCheckCompleted__c == null && (this.dailyActionRecord.ReadyToWork__c == 'Yes' || (this.dailyActionRecord.ReadyToWork__c == 'No' && (
            this.dailyActionRecord.CanYouProceedWithFirstSA__c == 'Yes')))
          ){
            this.disableVanCheck =  false;
          }else{
            this.disableVanCheck = true;
          }
          this.dailyActionsCompleted = (this.dailyActionRecord.ReadyToWork__c == 'Yes' || (this.dailyActionRecord.ReadyToWork__c  == 'No' && 
          this.dailyActionRecord.CanYouProceedWithFirstSA__c == 'Yes')) && (this.dailyActionRecord.VanCheckCompleted__c == 'Yes' || (this.dailyActionRecord.VanCheckCompleted__c == 'No' &&
                  this.dailyActionRecord.ReasonVanCheckCannotBeCompleted__c));
          this.canYouProceedWithSANo = this.dailyActionRecord.CanYouProceedWithFirstSA__c == 'No';
          this.isReadyToWorkNo = this.dailyActionRecord.ReadyToWork__c == 'No';
          if(!this.dailyActionRecord.ReadyToWork__c != null){
            this.readyToWork =  false;
          }
          
      })
      .catch(error => {
        this.firstScreenVisible = false;
        this.hasError = true;
        this.error = error.message.body;
       
      })
  }

@wire(getObjectInfo, { objectApiName: SERVICE_RESOURCE_STEPS })
serviceResourceStepInfo;

@wire(getPicklistValues, { recordTypeId: '$serviceResourceStepInfo.data.defaultRecordTypeId', fieldApiName: REASONNOVANCHECKCOMPLETED })
reasonNoVanCheckCompleted({ error, data }) {
  if (data) {
    this.vanCheckNotCompletedReason = data.values;
    this.error = undefined;
  } else if (error) {
    this.error = error;
    this.vanCheckNotCompletedReason = undefined;
  }
}

@wire(getPicklistValues, { recordTypeId: '$serviceResourceStepInfo.data.defaultRecordTypeId', fieldApiName: READYTOWORKYESNO })
picklistResults({ error, data }) {
  if (data) {
    this.picklistYesNo = data.values;
    this.error = undefined;
  } else if (error) {
    this.error = error;
    this.picklistYesNo = undefined;
  }
}

handleDailyVehicleClick(event){
    this.vehicleCheckVisible = true;
    this.readyToWork = false;
    this.firstScreenVisible = false;
}

handlReadyToWorkeClick(event){
    this.readyToWork = true;
    this.firstScreenVisible = false;
}

handleChange(event){
    this.readyToWorkValue = event.detail.value;
    this.dailyActionRecord.ReadyToWork__c = this.readyToWorkValue;
    if(this.readyToWorkValue == 'No'){
        this.isReadyToWorkNo = true;
    }else{
      this.isReadyToWorkNo = false;
    }
}

handleChangeCanYouNowProceed(event){
    this.canYouProceedWithSA = event.detail.value;
    this.dailyActionRecord.CanYouProceedWithFirstSA__c  = event.detail.value;
}

handleChangeVanCheckCompleted(event){
    this.vanCheckCompleted = event.detail.value;
    if(this.vanCheckCompleted == 'No'){
      this.vanCheckCompletedNo = true;
    }else{
      this.vanCheckCompletedNo = false;
      this.vanCheckNotCompletedReasonValue = null;
      this.dailyActionRecord.ReasonVanCheckCannotBeCompleted__c = null;
    }
    this.dailyActionRecord.VanCheckCompleted__c = this.vanCheckCompleted;
}

handleReasonChange(event){
    this.vanCheckNotCompletedReasonValue = event.detail.value;
    this.dailyActionRecord.ReasonVanCheckCannotBeCompleted__c = this.vanCheckNotCompletedReasonValue;
}


handleSubmit(event){
  this.isValid = false;
  this.dailyActionsCompleted = ((this.dailyActionRecord.ReadyToWork__c == 'Yes' || (this.dailyActionRecord.ReadyToWork__c  == 'No' && 
          this.dailyActionRecord.CanYouProceedWithFirstSA__c == 'Yes')) && (this.dailyActionRecord.VanCheckCompleted__c == 'Yes' || (this.dailyActionRecord.VanCheckCompleted__c == 'No' &&
                  this.dailyActionRecord.ReasonVanCheckCannotBeCompleted__c)));
  if(event.target.dataset.id == 'readyForWorkBtn'){
    if(this.isReadyToWorkNo){
      const calloutComments = this.template.querySelector('.callOutComeComments');
      const canYouProceedWithSAComp = this.template.querySelector('.canYouProceedWithSA');
      this.callComments = calloutComments.value;
      this.dailyActionRecord.OutcomeOfTLCall__c = this.callComments;
      if (!calloutComments.checkValidity()) {
          calloutComments.reportValidity();
      }
      else if (!this.canYouProceedWithSA) {
        canYouProceedWithSAComp.reportValidity();
      }
      else{
          this.isValid = true;
      }
    }else{
        this.isValid = true;
    }
  }

  if(event.target.dataset.id == 'vanCheckBtn'){
      const vanCheckReasonCmp = this.template.querySelector('.vanCheckReason');
      const vanCheckCmp = this.template.querySelector('.vanCheckCompleted');
      if (!this.vanCheckCompleted) {
        vanCheckCmp.reportValidity();
      }else if (this.vanCheckCompletedNo && !this.vanCheckNotCompletedReasonValue) {
        vanCheckReasonCmp.reportValidity();
      }else{
        this.isValid = true;
      }
  }
  if (this.isValid){
    this.updateDailyRecord();
  }
    
}

openDriverApp(){
        const urlToNavigate =  'https://apps.powerapps.com/play/e/default-c7337f18-48f0-40a9-b3af-f1321a74a12e/a/7149c4f5-ff6e-486b-84cb-d5c287da7eaa?tenantId=c7337f18-48f0-40a9-b3af-f1321a74a12e&hint=319987b1-cad7-4253-b546-c527d0f5ad13&sourcetime=1739818378746&source=portal';
        

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage', // Navigate to a web page
            attributes: {
                url: urlToNavigate
            }
        });
}

updateDailyRecord(){
    upadteDailyActionRecord({ aServiceResourceStepJSON: JSON.stringify(this.dailyActionRecord) })
    .then(() => {
      this.firstScreenVisible = true;
      this.vehicleCheckVisible = false;
      this.fetchDailyActionRecord();
      if((this.dailyActionRecord.ReadyToWork__c == 'No' && (
        this.dailyActionRecord.CanYouProceedWithFirstSA__c == 'No') || this.dailyActionRecord.VanCheckCompleted__c != null)
      ){
        this.disableVanCheck =  true;
      }else{
        this.disableVanCheck = false;
      }
    })
    .catch((error) => {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error creating record",
          message: error.body.message,
          variant: "error",
        }),
      );
    });

}
        
}