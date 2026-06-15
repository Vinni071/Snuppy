class CodeTemplate {
  final String title;
  final String description;
  final String code;

  const CodeTemplate({
    required this.title,
    required this.description,
    required this.code,
  });
}

class EditorTemplates {
  EditorTemplates._();

  static const List<CodeTemplate> templates = [
    CodeTemplate(
      title: '1. Hello Variable',
      description:
          'Learn variable declarations, basic math operations, and output printing.',
      code: r'''// Welcome to Snuppy!
// Let's declare some variables and print their sum.

var x = 15;
const y = 27;

var sum = x + y;
print(sum);
''',
    ),
    CodeTemplate(
      title: '2. Conditional Choices',
      description:
          'Explore logic using if-else branches and comparison operators.',
      code: r'''// Control flow block
var score = 85;

if score >= 90 {
  print("Excellent! Grade A");
} else {
  if score >= 70 {
    print("Good job! Grade B");
  } else {
    print("Keep studying! Grade C");
  }
}
''',
    ),
    CodeTemplate(
      title: '3. Factorial Loop',
      description:
          'Observe scope isolation and step-by-step state in a while loop.',
      code: r'''// Calculate factorial of 5 using a loop
var n = 5;
var result = 1;

while n > 1 {
  result = result * n;
  n = n - 1;
}

print(result);
''',
    ),
    CodeTemplate(
      title: '4. Functions & Scope',
      description:
          'Declare reusable functions and observe lexical environment stack.',
      code: r'''// Functions and local scopes
var factor = 2;

fn scale(number) {
  var localResult = number * factor;
  return localResult;
}

var original = 10;
var scaled = scale(original);

print(scaled);
''',
    ),
    CodeTemplate(
      title: '5. Did-You-Mean Error',
      description:
          'See the intelligent semantic analyzer detecting misspelled variables.',
      code: r'''// Oops! Typo detection
var myVariable = 100;

// The semantic analyzer will suggest the correct variable name:
print(myVarable);
''',
    ),
    CodeTemplate(
      title: '6. Scope Isolation Error',
      description:
          'Understand lexical scoping rules when accessing variables outside their block.',
      code: r'''// Scoping rule visualization
if true {
  var secretMessage = "Hidden inside block";
  print(secretMessage);
}

// This will error because secretMessage belongs to the block scope!
print(secretMessage);
''',
    ),
  ];
}
