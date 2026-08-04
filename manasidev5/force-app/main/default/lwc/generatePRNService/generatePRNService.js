const YH_ALLPAY_CLIENTCODE  = '98269064'; 
export function generatePRN(tenancyNumber, subAccountNumber, orchardCheckDigit) {
    let prnNumber;
    if(orchardCheckDigit && subAccountNumber && tenancyNumber){
        tenancyNumber = tenancyNumber.padStart(8, '0');
        prnNumber = YH_ALLPAY_CLIENTCODE  + tenancyNumber + subAccountNumber + orchardCheckDigit;
        let checkDigitLuhn = calculateLuhnCheckDigit(prnNumber);
        prnNumber = prnNumber + checkDigitLuhn;
    }
    return prnNumber;
}

function calculateLuhnCheckDigit(baseNumber) {
    let total = 0;
    const digits = baseNumber.split('').map(Number);
    const length = digits.length;
    for (let i = length - 1; i >= 0; i--) {
        let digit = digits[i];
        const posFromRight = length - 1 - i;
        
        // Alternate parity: double rightmost, then every second moving left
        if (posFromRight % 2 === 0) {
            digit *= 2;
            if (digit > 9) {
                digit -= 9;
            }
        }
        total += digit;
    }
    return (10 - (total % 10)) % 10;
}