import { generatePRN } from 'c/generatePRNService';

export function buildPaymentUrl(allPayBaseUrl, tenancyNumber, accountId, orchardChequeDigit) {
    let prnNumber;
    try {
        prnNumber = generatePRN(tenancyNumber, accountId, orchardChequeDigit);
    } catch (error) {
        prnNumber = null;
    }
    return prnNumber ? allPayBaseUrl + prnNumber : allPayBaseUrl;
}