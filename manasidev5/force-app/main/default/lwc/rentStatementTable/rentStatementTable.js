import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class MockTable extends LightningElement {
    
    @track transactions = []; // Use @track so UI updates when isExpanded changes
    @track formattedTransactions = [];
    @api isPrintView = false; 

    @api transactionData = []; // This will be set from the parent component 

    @track pageNumber = 1;
    @track pageSize = 10; 

    @wire(CurrentPageReference)
        currentPageReference;

    connectedCallback() {       
        this.formattedTransactions = this.transactionData.map((item, index) => ({
            ...item,
            benefits: item.benefits?.map((benefit, bindex) => ({
                ...benefit, amount: benefit?.amount?.toFixed(2), 
                id: `benefit-${index}-${bindex}`})) || [],
            rent: {...item.rent, id: `rent-${index}-0`, amount: item.rent?.amount?.toFixed(2)},
            payments: {
                paymentTransactions : item.payments?.map((payment, pindex) => ({
                    ...payment,
                    amount: payment?.amount?.toFixed(2),
                    id: `payment-${index}-${pindex}`
                })) || [],
            },
            payments: {
                paymentTransactions : item.payments?.map((payment, pindex) => ({
                    ...payment,
                    amount: payment?.amount?.toFixed(2),
                    id: `payment-${index}-${pindex}`
                })) || [],
            },
            adjustments: {
                adjustmentTransactions : item.adjustments?.map((adjustment, aindex) => ({
                    ...adjustment,
                    amount: adjustment?.amount?.toFixed(2),
                    id: `adjustment-${index}-${aindex}`
                })) || [],
            },
            charges: {
                chargeTransactions: item.charges?.chargesTransactions?.map((charge, cindex) => ({
                    ...charge,
                    amount: charge?.amount?.toFixed(2),
                    id: `charge-${index}-${cindex}`
                })) || [],
            },
            id: `tx-${index}`,
            isExpanded: false,
            iconName: 'utility:chevronright',
            detailClass: 'detail-row is-collapsed'
        }));
    }

    get currentDate() {
    return new Date().toLocaleDateString('en-GB', {
        day: 'numeric',
        month: 'long',
            year: 'numeric'
        });
    }

    get pagedTransactions() {
        try {
            const start = (this.pageNumber - 1) * this.pageSize;
            let end = this.pageSize * this.pageNumber;
            if (end >= this.formattedTransactions.length) {
                end = this.formattedTransactions.length;
            }
            const pagedTransactions = this.formattedTransactions.slice(start, end);
            return pagedTransactions;
        } catch (error) {
            console.error('Error in pagedTransactions:', error);
            return [];      
        }
    }

    handleNext() {
        if (this.pageNumber < this.totalPages) {
            this.pageNumber++;
        }
    }

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.pageNumber--;
        }
    }

    get totalPages() {
        return Math.ceil(this.formattedTransactions.length / this.pageSize);
    }

    get isFirstPage() {
        return this.pageNumber <= 1;
    }

    get isLastPage() {
        return this.pageNumber >= this.totalPages;
    }

    handleToggle(event) {
        const id = event.target.dataset.id;
        event.preventDefault();
        
        this.formattedTransactions = this.formattedTransactions.map(item => {
            if (item.id === id) {
                const expanded = !item.isExpanded;
                return {
                    ...item,
                    isExpanded: expanded,
                    iconName: expanded ? 'utility:chevrondown' : 'utility:chevronright',
                    detailClass: expanded ? 'detail-row' : 'detail-row is-collapsed'
                };
            }
            return item;
        });
    }

    get isGarageRent() {
        return this.currentPageReference.state.c__rentTag?.toLowerCase().includes("garage");
    }

    get hasPermissionViewBreakdowns() {
        return (this.rentTag !== 'Affordable Rent' && 
        this.rentTag !== 'Rent To Buy' &&
        this.rentTag !== 'Intermediate Rent' &&
        this.rentTag !== 'Supported Housing - Affordable Rent' &&
        this.rentTag !== 'Schemes - Affordable' &&
        this.rentTag !== 'Extra Care - Affordable' &&
        this.rentTag !== 'Garage Rent');
    }

    get rentTag() {
        return this.currentPageReference.state.c__rentTag;
    }

    get customerName() {
        return this.currentPageReference.state.c__customerName;
    }

    get tenancyNumber() {
        return this.currentPageReference.state.c__tenancyNumber;
    }

    get propertyType() {
        return this.currentPageReference.state.c__propertyType;
    }

    get accountType() {
        return this.currentPageReference.state.c__accountType;
    }

    get accountId() {
        return this.currentPageReference.state.c__accountId;
    }

    get propertyAddress() {
        return this.currentPageReference.state.c__pAddress;
    }

    get chargelabel() {
        if (this.accountType === 'Main Account') {
            return 'Rent';
        } else if (this.accountType === 'Chargeable Repairs') {
            return 'Charge';
        } else if (this.accountType === 'Legal Costs') {
            return 'Legal Cost';
        } else if (this.accountType === 'Admin Costs') {
            return 'Admin Charges';
        }
        return 'Charge';
    }

    get isMainAccount() {
        return this.accountType === 'Main Account';
    }

    @api print() {
       this.isPrintView = true;
       window.addEventListener('afterprint', () => {
            this.isPrintView = false;
        }, { once: true });

        setTimeout(() => {
            window.print();
        }, 500);

    }
}