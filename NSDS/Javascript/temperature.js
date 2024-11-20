const prompt = require('prompt-sync')();


let temperatures = [];
let temperature;
let sum = 0;
let min = Number.MAX_VALUE;
let max = Number.MIN_VALUE;
let count = 0;

while (temperature != 0) {
    temperature = prompt("What is the next temperature value? [0 to stop] ");
    if (temperature != 0) {
        temperatures.push(temperature);
        sum += parseFloat(temperature);
        count++;
        if (temperature < min) {
            min = temperature;
        }
        if (temperature > max) {
            max = temperature;
        }
    }
}

console.log("The average temperature is " + sum / count);
console.log("The minimum temperature is " + min);
console.log("The maximum temperature is " + max);
