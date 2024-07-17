let items = [];
let totalAmount = 0;
let currentBillId = 0;
let pendingBills = {};
let isJobWorker = false;
let maxBills = 3;

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'openRegister') {
        document.getElementById('register').style.display = 'block';
        document.getElementById('payment').style.display = 'none';
        document.getElementById('businessLogo').src = `nui://Noon-Payment/ui/images/${data.logo}`;
        populateItems(data.items);
    } else if (data.action === 'openPayment') {
        document.getElementById('register').style.display = 'none';
        document.getElementById('payment').style.display = 'block';
        document.getElementById('businessLogoPayment').src = `nui://Noon-Payment/ui/images/${data.logo}`;
        isJobWorker = data.isJobWorker;
        maxBills = data.maxBills;
        populateBills(data.bills);
    } else if (data.action === 'close') {
        document.getElementById('register').style.display = 'none';
        document.getElementById('payment').style.display = 'none';
        items = [];
        totalAmount = 0;
        updateItemList();
    } else if (data.action === 'updateBills') {
        pendingBills = data.bills;
    }
});

function populateItems(itemsList) {
    const itemContainer = document.getElementById('itemContainer');
    if (itemContainer) {
        itemContainer.innerHTML = '';
        itemsList.forEach(item => {
            const itemButton = document.createElement('button');
            itemButton.className = 'button item';
            itemButton.dataset.price = item.price;
            itemButton.innerHTML = `<img src="nui://Noon-Payment/ui/images/${item.image}" alt="${item.name}" class="item-image">${item.name} - $${item.price}`;
            itemButton.onclick = function() {
                addItem(item.name, item.price);
            };
            itemContainer.appendChild(itemButton);
        });
    }
}

function populateBills(bills) {
    const billList = document.getElementById('billList');
    if (billList) {
        billList.innerHTML = '';

        if (Object.keys(bills).length === 0) {
            billList.innerHTML = '<p>No active bills</p>';
            return;
        }

        // Limit to maximum active bills
        const billEntries = Object.entries(bills).slice(0, maxBills);

        for (const [billId, bill] of billEntries) {
            const billItem = document.createElement('div');
            billItem.className = 'billItem';
            billItem.innerHTML = `
                <p>Order #${billId}: $${bill.totalAmount.toFixed(2)}</p>
                <button class="button pay" onclick="payBill(${billId})">Pay</button>
                ${isJobWorker ? `<button class="button cancel" onclick="cancelBill(${billId})">Cancel</button>` : ''}
            `;
            billList.appendChild(billItem);
        }
    }
}

function addItem(name, price) {
    const existingItem = items.find(item => item.name === name);
    if (existingItem) {
        existingItem.quantity += 1;
    } else {
        items.push({ name, price, quantity: 1 });
    }
    totalAmount += price;
    updateItemList();
}

function updateItemList() {
    const itemList = document.getElementById('itemList');
    if (itemList) {
        itemList.innerHTML = '';
    
        items.forEach((item) => {
            const listItem = document.createElement('li');
            listItem.innerText = `${item.name} x${item.quantity}: $${(item.price * item.quantity).toFixed(2)}`;
            itemList.appendChild(listItem);
        });

        document.getElementById('totalAmount').innerText = totalAmount.toFixed(2);
    }
}

function confirmBill() {
    if (Object.keys(pendingBills).length >= maxBills) {
        alert('Maximum number of active bills reached. Please process existing bills before creating new ones.');
        return;
    }

    currentBillId += 1;
    fetch(`https://${GetParentResourceName()}/submitBill`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ items, totalAmount, billId: currentBillId })
    }).then(resp => resp.json()).then(resp => {
        if (resp.status === 'ok') {
            fetch(`https://${GetParentResourceName()}/escape`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({})
            });
        }
    });
}

function payBill(billId) {
    fetch(`https://${GetParentResourceName()}/payBill`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ billId })
    }).then(resp => resp.json()).then(resp => {
        if (resp.status === 'ok') {
            fetch(`https://${GetParentResourceName()}/escape`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({})
            });
        }
    });
}

function cancelBill(billId) {
    fetch(`https://${GetParentResourceName()}/cancelBill`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ billId })
    }).then(resp => resp.json()).then(resp => {
        if (resp.status === 'ok') {
            fetch(`https://${GetParentResourceName()}/escape`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({})
            });
        }
    });
}

document.onkeydown = function (e) {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/escape`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        }).then(resp => resp.json()).then(resp => {
            if (resp === 'ok') {
                document.getElementById('register').style.display = 'none';
                document.getElementById('payment').style.display = 'none';
                items = [];
                totalAmount = 0;
                updateItemList();
            }
        });
    }
};
