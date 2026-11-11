class CodeTemplate {
  final String title;
  final String description;
  final String code;
  final String category;
  final String fileName;

  /// Short excerpt shown on the template card.
  final String preview;

  const CodeTemplate({
    required this.title,
    required this.description,
    required this.code,
    required this.category,
    required this.fileName,
    required this.preview,
  });
}

class EditorTemplates {
  EditorTemplates._();

  /// Filter value that matches every category.
  static const allCategories = 'Todos';

  static const categories = [
    allCategories,
    'Fundamentos',
    'Controle de fluxo',
    'Funções',
    'Depuração',
  ];

  static const List<CodeTemplate> templates = [
    CodeTemplate(
      title: 'Olá, variáveis',
      description:
          'Dê o primeiro passo com variáveis, operações e saída de dados.',
      category: 'Fundamentos',
      fileName: 'ola-variaveis.lumi',
      preview: 'var ideia = 15;\nconst passo = 27;\nprint(ideia + passo);',
      code: r'''// Seu primeiro programa em Lumi.
var x = 15;
const y = 27;

var soma = x + y;
print(soma);
''',
    ),
    CodeTemplate(
      title: 'Decisões com if e else',
      description: 'Crie caminhos diferentes usando condições e comparações.',
      category: 'Controle de fluxo',
      fileName: 'condicionais.lumi',
      preview: 'if nota >= 70 {\n  print("Muito bem!");\n}',
      code: r'''// Escolha um caminho de acordo com a nota.
var nota = 85;

if nota >= 90 {
  print("Excelente! Conceito A");
} else {
  if nota >= 70 {
    print("Muito bem! Conceito B");
  } else {
    print("Continue estudando! Conceito C");
  }
}
''',
    ),
    CodeTemplate(
      title: 'Repetições e fatorial',
      description: 'Acompanhe as variáveis a cada volta de um laço while.',
      category: 'Controle de fluxo',
      fileName: 'fatorial.lumi',
      preview: 'while n > 1 {\n  resultado = resultado * n;\n}',
      code: r'''// Calcule o fatorial de 5.
var n = 5;
var resultado = 1;

while n > 1 {
  resultado = resultado * n;
  n = n - 1;
}

print(resultado);
''',
    ),
    CodeTemplate(
      title: 'Funções e escopos',
      description: 'Reutilize seu código e explore o escopo de cada variável.',
      category: 'Funções',
      fileName: 'funcoes.lumi',
      preview: 'fn escalar(numero) {\n  return numero * fator;\n}',
      code: r'''// Funções têm seu próprio escopo.
var fator = 2;

fn escalar(numero) {
  var resultadoLocal = numero * fator;
  return resultadoLocal;
}

var original = 10;
var escalado = escalar(original);
print(escalado);
''',
    ),
    CodeTemplate(
      title: 'Aprendendo com erros',
      description:
          'Descubra como o analisador sugere correções para seu código.',
      category: 'Depuração',
      fileName: 'diagnosticos.lumi',
      preview:
          'var minhaVariavel = 100;\nprint(minhaVarivel);\n// Encontre o erro ↑',
      code: r'''// Um erro intencional para explorar os diagnósticos.
var minhaVariavel = 100;

// Observe a sugestão para o nome digitado incorretamente.
print(minhaVarivel);
''',
    ),
    CodeTemplate(
      title: 'Os limites de um escopo',
      description:
          'Entenda por que uma variável pertence ao bloco em que nasceu.',
      category: 'Depuração',
      fileName: 'escopos.lumi',
      preview: 'if true {\n  var mensagem = "Olá!";\n}',
      code: r'''// Uma variável criada no bloco fica dentro dele.
if true {
  var mensagem = "Dentro do bloco";
  print(mensagem);
}

// Erro intencional: mensagem não existe neste escopo.
print(mensagem);
''',
    ),
  ];
}
