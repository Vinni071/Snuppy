class CodeTemplate {
  final String title;
  final String description;
  final String code;
  final String category;
  final String fileName;

  const CodeTemplate({
    required this.title,
    required this.description,
    required this.code,
    required this.category,
    required this.fileName,
  });
}

class EditorTemplates {
  EditorTemplates._();

  static const List<CodeTemplate> templates = [
    CodeTemplate(
      title: 'Olá, variáveis',
      description:
          'Dê o primeiro passo com variáveis, operações e saída de dados.',
      category: 'Fundamentos',
      fileName: 'ola-variaveis.lumi',
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
