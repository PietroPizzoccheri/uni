const prompt = require('prompt-sync')();

class AddressBookEntry {
    constructor(name, address, civicNumber, zipCode) {
        this.name = name;
        this.address = address;
        this.civicNumber = civicNumber;
        this.zipCode = zipCode;
    }

    showInfo() {
        console.log("Name: " + this.name);
        console.log("Address: " + this.address);
        console.log("Civic Number: " + this.civicNumber);
        console.log("Zip Code: " + this.zipCode);
    }
}

let name = prompt("Enter the name: ");
let address = prompt("Enter the address: ");
let civicNumber = prompt("Enter the civic number: ");
let zipCode = prompt("Enter the zip code: ");

let entry = new AddressBookEntry(name, address, civicNumber, zipCode);
entry.showInfo();