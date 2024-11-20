const prompt = require('prompt-sync')();

let date = new Date();

console.log(date.getDate());
console.log(date.getMonth());
console.log(date.getFullYear());

let day = prompt("Enter the day of your birthday: ");
let month = prompt("Enter the month of your birthday: ");
let year = prompt("Enter the year of your birthday: ");

const ageInDays = (date.getFullYear() - year) * 365 + (date.getMonth() - month) * 30 + (date.getDate() - day);

console.log("you have " + ageInDays + " days");