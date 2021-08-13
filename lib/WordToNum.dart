int wordToNumber(String input) {
  bool isValidInput = true;
  int result = 0;
  int finalResult = 0;
  List<String> allowedStrings = [
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
    "ten",
    "eleven",
    "twelve",
    "thirteen",
    "fourteen",
    "fifteen",
    "sixteen",
    "seventeen",
    "eighteen",
    "nineteen",
    "twenty",
    "thirty",
    "forty",
    "fifty",
    "sixty",
    "seventy",
    "eighty",
    "ninety",
    "hundred",
    "thousand",
    "million",
    "billion",
    "trillion"
  ];

  if (input != null && input.length > 0) {
    input = input.replaceAll("-", " ");
    input = input.toLowerCase().replaceAll(" and", "");
    List splittedParts = input.split(" ");

    for (var a = 0; a < splittedParts.length; a++) {
      if (!allowedStrings.contains(splittedParts[a])) {
        isValidInput = false;
        break;
      }
    }
    if (isValidInput) {
      for (var a = 0; a < splittedParts.length; a++) {
        if (splittedParts[a].toString().compareTo("zero") == 0) {
          result += 0;
        } else if (splittedParts[a].toString().compareTo("one") == 0) {
          result += 1;
        } else if (splittedParts[a].toString().compareTo("two") == 0) {
          result += 2;
        } else if (splittedParts[a].toString().compareTo("three") == 0) {
          result += 3;
        } else if (splittedParts[a].toString().compareTo("four") == 0) {
          result += 4;
        } else if (splittedParts[a].toString().compareTo("five") == 0) {
          result += 5;
        } else if (splittedParts[a].toString().compareTo("six") == 0) {
          result += 6;
        } else if (splittedParts[a].toString().compareTo("seven") == 0) {
          result += 7;
        } else if (splittedParts[a].toString().compareTo("eight") == 0) {
          result += 8;
        } else if (splittedParts[a].toString().compareTo("nine") == 0) {
          result += 9;
        } else if (splittedParts[a].toString().compareTo("ten") == 0) {
          result += 10;
        } else if (splittedParts[a].toString().compareTo("eleven") == 0) {
          result += 11;
        } else if (splittedParts[a].toString().compareTo("twelve") == 0) {
          result += 12;
        } else if (splittedParts[a].toString().compareTo("thirteen") == 0) {
          result += 13;
        } else if (splittedParts[a].toString().compareTo("fourteen") == 0) {
          result += 14;
        } else if (splittedParts[a].toString().compareTo("fifteen") == 0) {
          result += 15;
        } else if (splittedParts[a].toString().compareTo("sixteen") == 0) {
          result += 16;
        } else if (splittedParts[a].toString().compareTo("seventeen") == 0) {
          result += 17;
        } else if (splittedParts[a].toString().compareTo("eighteen") == 0) {
          result += 18;
        } else if (splittedParts[a].toString().compareTo("nineteen") == 0) {
          result += 19;
        } else if (splittedParts[a].toString().compareTo("twenty") == 0) {
          result += 20;
        } else if (splittedParts[a].toString().compareTo("thirty") == 0) {
          result += 30;
        } else if (splittedParts[a].toString().compareTo("forty") == 0) {
          result += 40;
        } else if (splittedParts[a].toString().compareTo("fifty") == 0) {
          result += 50;
        } else if (splittedParts[a].toString().compareTo("sixty") == 0) {
          result += 60;
        } else if (splittedParts[a].toString().compareTo("seventy") == 0) {
          result += 70;
        } else if (splittedParts[a].toString().compareTo("eighty") == 0) {
          result += 80;
        } else if (splittedParts[a].toString().compareTo("ninety") == 0) {
          result += 90;
        } else if (splittedParts[a].toString().compareTo("hundred") == 0) {
          result *= 100;
        } else if (splittedParts[a].toString().compareTo("thousand") == 0) {
          result *= 1000;
          finalResult += result;
          result = 0;
        } else if (splittedParts[a].toString().compareTo("million") == 0) {
          result *= 1000000;
          finalResult += result;
          result = 0;
        } else if (splittedParts[a].toString().compareTo("billion") == 0) {
          result *= 1000000000;
          finalResult += result;
          result = 0;
        }
      }

      finalResult += result;
      result = 0;
    }
  }

  return finalResult;
}
