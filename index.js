// Palindrome Checker
function isPalindrome(str) {
    const len = str.length;
    for (let i = 0; i < len / 2; i++) {
        if (str[i] !== str[len - 1 - i]) {
            return false;
        }
    }
    return true;
}

function checkPalindrome() {
    const inputPalindrome = document.getElementById('inputPalindrome').value;
    const palindromeResultElement = document.getElementById('palindromeResult');

    const strippedInput = inputPalindrome.replace(/\s/g, '');

    if (isPalindrome(strippedInput)) {
        palindromeResultElement.textContent = 'The entered string is a palindrome.';
    } else {
        palindromeResultElement.textContent = 'The entered string is not a palindrome.';
    }
}

// Vowel and Consonant Counter
function countCharacters() {
    const inputString = document.getElementById('inputString').value.toLowerCase();
    const vowels = 'aeiou';
    let vowelCount = 0;
    let consonantCount = 0;

    for (let char of inputString) {
        if (/[a-z]/.test(char)) {
            if (vowels.includes(char)) {
                vowelCount++;
            } else {
                consonantCount++;
            }
        }
    }

    const characterCountResultElement = document.getElementById('characterCountResult');
    characterCountResultElement.innerHTML = `<p>Vowels: ${vowelCount}</p><p>Consonants: ${consonantCount}</p>`;
}

// Tip Calculator
function calculateTotal() {
    const subtotal = parseFloat(document.getElementById('subtotal').value);
    const tipPercentage = parseFloat(document.getElementById('tipPercentage').value);

    if (isNaN(subtotal) || isNaN(tipPercentage)) {
        alert("Please enter valid numbers for Subtotal and Tip Percentage.");
        return;
    }

    const tipAmount = (subtotal * tipPercentage) / 100;
    const totalAmount = subtotal + tipAmount;

    const totalAmountElement = document.getElementById('totalAmount');
    totalAmountElement.textContent = `Total amount to be paid (including tip): $${totalAmount.toFixed(2)}`;
}
