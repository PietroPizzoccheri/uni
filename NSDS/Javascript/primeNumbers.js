const prompt = require('prompt-sync')();

class PrimeNumbers {
    constructor(k, primes) {
        this.k = k;
        this.primes = primes;
    }

    showInfo() {
        console.log(`k: ${this.k}`);
        console.log(`Primes up to ${this.k}: ${this.primes.join(', ')}`);
    }
}

function primesToNumber(number) {
    let primes = [];
    for (let i = 2; i <= number; i++) {
        let isPrime = true;
        for (let j = 2; j <= Math.sqrt(i); j++) {
            if (i % j === 0) {
                isPrime = false;
                break;
            }
        }
        if (isPrime) {
            primes.push(i);
        }
    }
    return primes;
}

let n = parseInt(prompt("Enter a number: "), 10);
let array = [];

for (let k = 2; k <= n; k++) {
    let primesArray = primesToNumber(k);
    let entry = new PrimeNumbers(k, primesArray);
    array.push(entry);
}

array.forEach(entry => entry.showInfo());