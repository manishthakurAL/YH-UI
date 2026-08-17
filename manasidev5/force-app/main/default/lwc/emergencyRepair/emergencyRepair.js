import { LightningElement } from 'lwc';
import CP_WhatIsAnEmergency from '@salesforce/label/c.CP_WhatIsAnEmergency';
import CP_EmergencyItemElectricityGasWater from '@salesforce/label/c.CP_EmergencyItemElectricityGasWater';
import CP_EmergencyItemUnsafePower from '@salesforce/label/c.CP_EmergencyItemUnsafePower';
import CP_EmergencyItemBlockedFlue from '@salesforce/label/c.CP_EmergencyItemBlockedFlue';
import CP_EmergencyItemTotalLossHeating from '@salesforce/label/c.CP_EmergencyItemTotalLossHeating';
import CP_EmergencyItemTapsRunning from '@salesforce/label/c.CP_EmergencyItemTapsRunning';
import CP_EmergencyItemWaterLeak from '@salesforce/label/c.CP_EmergencyItemWaterLeak';
import CP_EmergencyItemHomeInsecure from '@salesforce/label/c.CP_EmergencyItemHomeInsecure';
import CP_EmergencyItemExternalDoor from '@salesforce/label/c.CP_EmergencyItemExternalDoor';
import CP_EmergencyItemRoofLeak from '@salesforce/label/c.CP_EmergencyItemRoofLeak';
import CP_EmergencyItemHotWater from '@salesforce/label/c.CP_EmergencyItemHotWater';
import CP_EmergencyItemMould from '@salesforce/label/c.CP_EmergencyItemMould';
import CP_GasLeaks from '@salesforce/label/c.CP_GasLeaks';
import CP_GasLeaksMessage from '@salesforce/label/c.CP_GasLeaksMessage';

export default class emergencyRepair extends LightningElement {
    isExpanded = false;

    label = {
        whatIsAnEmergency: CP_WhatIsAnEmergency,
        emergencyItemElectricityGasWater: CP_EmergencyItemElectricityGasWater,
        emergencyItemUnsafePower: CP_EmergencyItemUnsafePower,
        emergencyItemBlockedFlue: CP_EmergencyItemBlockedFlue,
        emergencyItemTotalLossHeating: CP_EmergencyItemTotalLossHeating,
        emergencyItemTapsRunning: CP_EmergencyItemTapsRunning,
        emergencyItemWaterLeak: CP_EmergencyItemWaterLeak,
        emergencyItemHomeInsecure: CP_EmergencyItemHomeInsecure,
        emergencyItemExternalDoor: CP_EmergencyItemExternalDoor,
        emergencyItemRoofLeak: CP_EmergencyItemRoofLeak,
        emergencyItemHotWater: CP_EmergencyItemHotWater,
        emergencyItemMould: CP_EmergencyItemMould,
        gasLeaks: CP_GasLeaks,
        gasLeaksMessage: CP_GasLeaksMessage
    };

    toggleExpanded() {
        this.isExpanded = !this.isExpanded;
    }
}