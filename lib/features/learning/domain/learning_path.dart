/// The course only uses syntax supported by the bundled Lumi interpreter.
class LumiLesson {
  final String id;
  final String title;
  final int minutes;
  final String explanation;
  final String code;
  final String output;
  final String challenge;
  final String question;
  final List<String> answers;
  final int correctAnswer;
  final String feedback;
  final bool isProject;

  const LumiLesson({
    required this.id,
    required this.title,
    required this.minutes,
    required this.explanation,
    required this.code,
    required this.output,
    required this.challenge,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.feedback,
    this.isProject = false,
  });

  int get xp => isProject ? 100 : 50;
}

class LumiModule {
  final String title;
  final String subtitle;
  final String badge;
  final List<LumiLesson> lessons;

  const LumiModule({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.lessons,
  });
}

class LearningPath {
  LearningPath._();

  static final lessons =
      List<LumiLesson>.unmodifiable(modules.expand((module) => module.lessons));

  static LumiLesson? lessonById(String id) {
    for (final lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  static const modules = [
    LumiModule(
      title: 'A primeira faísca',
      subtitle: 'Pense em passos. Dê vida à sua primeira ideia.',
      badge: 'Primeira faísca',
      lessons: [
        LumiLesson(
          id: 'primeiro-programa',
          title: 'Olá, Lumi!',
          minutes: 5,
          explanation:
              'Um algoritmo é uma sequência de passos para resolver um problema. '
              'Um programa escreve esses passos em uma linguagem que o computador consegue executar. '
              'Na Lumi, print mostra o resultado no console. Textos ficam entre aspas.',
          code: 'print("Olá, mundo!");',
          output: 'Olá, mundo!',
          challenge:
              'Troque a mensagem por uma apresentação sua e toque em Execute. '
              'Observe o texto no console.',
          question: 'Qual comando mostra uma mensagem no console?',
          answers: ['print("Olá!");', 'var mensagem = "Olá!";', '// Olá!'],
          correctAnswer: 0,
          feedback:
              'print exibe um valor. Guardar um texto em uma variável ou escrever um comentário não o exibe.',
        ),
        LumiLesson(
          id: 'sequencia',
          title: 'Um passo de cada vez',
          minutes: 5,
          explanation: 'O computador segue a ordem das instruções. '
              'Linhas que começam com // são comentários: explicam o código e não são executadas. '
              'Mudar a ordem das instruções pode mudar o resultado do algoritmo.',
          code:
              '// Um algoritmo para plantar\nprint("Preparar a terra");\nprint("Plantar a semente");\nprint("Regar");',
          output: 'Preparar a terra\nPlantar a semente\nRegar',
          challenge:
              'Escreva três passos de uma tarefa do seu dia usando print. '
              'Acrescente um comentário explicando a tarefa.',
          question: 'O que acontece com a linha que começa com //?',
          answers: [
            'Ela aparece no console.',
            'Ela se repete.',
            'Ela não é executada.'
          ],
          correctAnswer: 2,
          feedback:
              'Comentários ajudam quem lê o programa, mas o interpretador não os executa.',
        ),
        LumiLesson(
          id: 'cartao-visita',
          title: 'Seu cartão de visita',
          minutes: 8,
          isProject: true,
          explanation:
              'Vamos juntar sequência, texto e saída em um pequeno projeto. '
              'Antes de executar, leia o código e tente prever o console. '
              'Comparar uma previsão com o resultado é uma boa forma de entender um programa.',
          code:
              'print("Meu nome é Lumi");\nprint("Quero aprender a programar");\nprint(2026);',
          output: 'Meu nome é Lumi\nQuero aprender a programar\n2026',
          challenge:
              'Personalize o cartão com seu nome, um objetivo e um número favorito. '
              'Execute e confira se as três linhas aparecem na ordem planejada.',
          question: 'Quantas linhas o exemplo imprime no console?',
          answers: ['Uma linha.', 'Três linhas.', 'Quatro linhas.'],
          correctAnswer: 1,
          feedback:
              'Cada uma das três chamadas de print produz uma linha no console.',
        ),
      ],
    ),
    LumiModule(
      title: 'Uma memória para criar',
      subtitle: 'Guarde informações e transforme valores.',
      badge: 'Mente curiosa',
      lessons: [
        LumiLesson(
          id: 'variaveis',
          title: 'Caixinhas de informação',
          minutes: 7,
          explanation:
              'Uma variável associa um nome a um valor. Use var para criar um valor que pode mudar '
              'e const para um valor que não pode ser reatribuído. O sinal = guarda o valor da direita no nome à esquerda.',
          code:
              'var pontos = 10;\nconst bonus = 5;\npontos = pontos + bonus;\nprint(pontos);',
          output: '15',
          challenge:
              'Mude os pontos iniciais para 20. Execute e acompanhe o valor de pontos na aba Depuração.',
          question: 'Qual é o valor de pontos ao final do exemplo original?',
          answers: ['10', '5', '15'],
          correctAnswer: 2,
          feedback: 'pontos começa em 10 e recebe 10 + 5. O novo valor é 15.',
        ),
        LumiLesson(
          id: 'tipos-operacoes',
          title: 'Valores e operações',
          minutes: 8,
          explanation:
              'A Lumi trabalha com inteiros, decimais, textos, booleanos (true e false) e nulo. '
              'O tipo é inferido do valor, sem anotação. Use +, -, * e / para calcular e parênteses para agrupar operações. '
              'Multiplicação e divisão têm prioridade sobre soma e subtração.',
          code:
              'var preco = 12.5;\nvar quantidade = 2;\nvar total = preco * quantidade;\nprint(total);\nprint(2 + 3 * 4);',
          output: '25\n14',
          challenge:
              'Altere a quantidade para 3. Depois compare 2 + 3 * 4 com (2 + 3) * 4.',
          question: 'Qual é o resultado de (2 + 3) * 4?',
          answers: ['20', '14', '9'],
          correctAnswer: 0,
          feedback:
              'Os parênteses fazem 2 + 3 ser calculado primeiro. Depois, 5 * 4 resulta em 20.',
        ),
        LumiLesson(
          id: 'orcamento',
          title: 'Uma compra planejada',
          minutes: 10,
          isProject: true,
          explanation: 'Decompor um problema é dividi-lo em partes menores. '
              'Para calcular o troco, precisamos do orçamento, do preço e da quantidade. '
              'Dê nomes claros a essas informações e calcule uma etapa de cada vez.',
          code:
              'const orcamento = 50;\nvar preco = 8;\nvar quantidade = 4;\nvar total = preco * quantidade;\nvar troco = orcamento - total;\nprint(total);\nprint(troco);',
          output: '32\n18',
          challenge:
              'Planeje uma compra com orçamento de 80, preço de 12 e quantidade de 5. '
              'Confira se o total é 60 e o troco é 20.',
          question: 'Qual expressão calcula o troco?',
          answers: [
            'total - orcamento',
            'orcamento - total',
            'orcamento + total'
          ],
          correctAnswer: 1,
          feedback: 'O troco é o dinheiro disponível menos o valor gasto.',
        ),
      ],
    ),
    LumiModule(
      title: 'Escolha seu caminho',
      subtitle: 'Ensine seu programa a tomar decisões.',
      badge: 'Explorador de caminhos',
      lessons: [
        LumiLesson(
          id: 'comparacoes',
          title: 'Verdadeiro ou falso?',
          minutes: 7,
          explanation: 'Comparações produzem booleanos: true ou false. '
              'Use == para comparar igualdade, != para diferença e >, <, >=, <= para comparar números. '
              'Combine condições com and, or e not. Lembre: = atribui; == compara.',
          code:
              'var idade = 18;\nvar temConvite = true;\nprint(idade >= 18 and temConvite);\nprint(not temConvite);',
          output: 'true\nfalse',
          challenge:
              'Troque temConvite por false e preveja as duas saídas antes de executar.',
          question: 'Quando A and B é verdadeiro?',
          answers: [
            'Quando apenas A é verdadeiro.',
            'Quando qualquer um é verdadeiro.',
            'Quando os dois são verdadeiros.'
          ],
          correctAnswer: 2,
          feedback:
              'and exige que as duas condições sejam verdadeiras. or exige pelo menos uma.',
        ),
        LumiLesson(
          id: 'condicionais',
          title: 'Decisões com if e else',
          minutes: 8,
          explanation: 'if executa um bloco quando a condição é verdadeira. '
              'else oferece um caminho para quando ela é falsa. As chaves delimitam cada bloco. '
              'Teste também o valor exato do limite para entender o papel de >= e >.',
          code:
              'var nota = 7;\nif nota >= 7 {\n  print("Aprovado");\n} else {\n  print("Tente novamente");\n}',
          output: 'Aprovado',
          challenge:
              'Execute com notas 6, 7 e 8. Confira qual bloco é executado em cada caso.',
          question:
              'Com nota = 7 e condição nota > 7, qual bloco seria executado?',
          answers: ['O bloco else.', 'O bloco if.', 'Os dois blocos.'],
          correctAnswer: 0,
          feedback:
              '7 não é maior que 7. Com > a condição é falsa; com >= seria verdadeira.',
        ),
        LumiLesson(
          id: 'porteiro',
          title: 'O guardião da entrada',
          minutes: 10,
          isProject: true,
          explanation:
              'Regras do mundo real podem virar condições. Neste projeto, a entrada exige '
              'idade mínima e convite. Teste combinações diferentes para verificar a regra inteira.',
          code:
              'var idade = 20;\nvar temConvite = true;\nif idade >= 18 and temConvite {\n  print("Entrada liberada");\n} else {\n  print("Entrada negada");\n}',
          output: 'Entrada liberada',
          challenge:
              'Teste idade 17 com convite, idade 18 sem convite e idade 18 com convite. '
              'Só o último caso deve liberar a entrada.',
          question:
              'Uma pessoa de 20 anos sem convite pode entrar com essa regra?',
          answers: [
            'Sim, pois tem mais de 18 anos.',
            'Não, as duas condições são necessárias.',
            'Sim, pois and significa ou.'
          ],
          correctAnswer: 1,
          feedback:
              'A idade atende ao limite, mas temConvite é false. Com and, a entrada é negada.',
        ),
      ],
    ),
    LumiModule(
      title: 'O poder de repetir',
      subtitle: 'Resolva mais com laços e acumuladores.',
      badge: 'Mestre dos laços',
      lessons: [
        LumiLesson(
          id: 'while',
          title: 'Enquanto houver caminho',
          minutes: 8,
          explanation:
              'while repete um bloco enquanto uma condição for verdadeira. '
              'Um contador acompanha as repetições. Atualize o contador para que a condição '
              'possa se tornar falsa; sem isso, o programa pode repetir indefinidamente.',
          code:
              'var contador = 1;\nwhile contador <= 3 {\n  print(contador);\n  contador = contador + 1;\n}',
          output: '1\n2\n3',
          challenge:
              'Faça o programa contar de 1 a 5. Na depuração, observe o contador mudar em cada volta.',
          question: 'Por que somamos 1 ao contador dentro do laço?',
          answers: [
            'Para criar uma constante.',
            'Para imprimir um texto.',
            'Para avançar até a condição ficar falsa.'
          ],
          correctAnswer: 2,
          feedback:
              'O contador precisa avançar. Quando ultrapassa 3, a condição do exemplo fica falsa e o laço termina.',
        ),
        LumiLesson(
          id: 'for',
          title: 'Repetições com for',
          minutes: 7,
          explanation:
              'Quando a quantidade de repetições é conhecida, use for i in N. '
              'Na Lumi, i percorre os inteiros de 0 até N - 1. Portanto, for i in 3 visita 0, 1 e 2. '
              'Use i + 1 quando quiser apresentar uma contagem a partir de 1.',
          code: 'for i in 3 {\n  print(i);\n}',
          output: '0\n1\n2',
          challenge:
              'Mude para for i in 5 e imprima i + 1. O console deve mostrar os números de 1 a 5.',
          question: 'Qual é o último valor de i em for i in 4?',
          answers: ['3', '4', '5'],
          correctAnswer: 0,
          feedback:
              'O laço começa em 0 e termina em N - 1. Com N igual a 4, o último valor é 3.',
        ),
        LumiLesson(
          id: 'acumulador',
          title: 'Uma soma a cada passo',
          minutes: 10,
          isProject: true,
          explanation: 'Um acumulador guarda um resultado parcial. '
              'Ele é criado antes do laço e atualizado em cada repetição. '
              'Para somar valores, começamos em zero e acrescentamos cada parcela.',
          code:
              'var soma = 0;\nfor i in 5 {\n  soma = soma + (i + 1);\n}\nprint(soma);',
          output: '15',
          challenge:
              'Some os números de 1 a 10. Use a depuração para conferir os resultados parciais e o total 55.',
          question: 'Por que soma é criada antes do laço?',
          answers: [
            'Para que seja sempre zero.',
            'Para preservar o total entre as repetições.',
            'Para impedir a execução do laço.'
          ],
          correctAnswer: 1,
          feedback:
              'O acumulador precisa manter o resultado anterior para acrescentar a próxima parcela.',
        ),
      ],
    ),
    LumiModule(
      title: 'Pequenas peças, grandes ideias',
      subtitle: 'Organize soluções com funções e escopos.',
      badge: 'Construtor de soluções',
      lessons: [
        LumiLesson(
          id: 'funcoes',
          title: 'Crie suas ferramentas',
          minutes: 8,
          explanation: 'Uma função dá nome a uma tarefa reutilizável. '
              'Declare com fn, receba valores por parâmetros e devolva um resultado com return. '
              'Declarar uma função não executa seu corpo: é preciso chamá-la.',
          code:
              'fn dobro(numero) {\n  return numero * 2;\n}\nprint(dobro(6));\nprint(dobro(9));',
          output: '12\n18',
          challenge:
              'Crie a função triplo(numero) e teste com 4 e 7. Espere 12 e 21.',
          question: 'Qual é o papel de return?',
          answers: [
            'Repetir a função para sempre.',
            'Mostrar sempre um texto no console.',
            'Devolver um valor a quem chamou a função.'
          ],
          correctAnswer: 2,
          feedback:
              'return devolve o resultado da função. Para mostrá-lo no console, usamos print.',
        ),
        LumiLesson(
          id: 'escopos',
          title: 'Cada valor no seu lugar',
          minutes: 8,
          explanation: 'Escopo é a região em que um nome pode ser usado. '
              'Uma variável criada em uma função é local a ela. Um nome local pode esconder um nome externo '
              'sem mudar o valor externo. Observe os dois escopos na depuração.',
          code:
              'var valor = 10;\nfn mostrar() {\n  var valor = 3;\n  print(valor);\n}\nmostrar();\nprint(valor);',
          output: '3\n10',
          challenge:
              'Mude apenas o valor local para 8 e confirme que o valor externo continua sendo 10.',
          question: 'Qual valor é impresso pela última linha do exemplo?',
          answers: ['10', '3', '13'],
          correctAnswer: 0,
          feedback:
              'A variável local da função não substitui a variável externa. Fora da função, valor continua sendo 10.',
        ),
        LumiLesson(
          id: 'calculadora',
          title: 'Sua calculadora de áreas',
          minutes: 12,
          isProject: true,
          explanation: 'Uma função pode receber mais de um parâmetro. '
              'Separe os parâmetros com vírgula e passe os argumentos na mesma ordem. '
              'Assim, uma única fórmula resolve vários casos sem copiar o código.',
          code:
              'fn areaRetangulo(base, altura) {\n  return base * altura;\n}\nprint(areaRetangulo(4, 3));\nprint(areaRetangulo(5, 2));',
          output: '12\n10',
          challenge:
              'Crie perimetroRetangulo(base, altura), usando 2 * (base + altura). '
              'Teste com base 4 e altura 3: o perímetro deve ser 14.',
          question: 'Quanto areaRetangulo(6, 3) devolve?',
          answers: ['9', '18', '6'],
          correctAnswer: 1,
          feedback:
              'Os argumentos 6 e 3 ocupam base e altura. A função devolve 6 * 3, ou seja, 18.',
        ),
      ],
    ),
    LumiModule(
      title: 'Da ideia à solução',
      subtitle: 'Investigue, teste e construa seu projeto final.',
      badge: 'Criador Lumi',
      lessons: [
        LumiLesson(
          id: 'depuracao',
          title: 'Aprenda com os erros',
          minutes: 10,
          explanation:
              'Erros de sintaxe quebram a escrita do programa; erros semânticos envolvem nomes e usos inválidos. '
              'Já um erro de lógica pode executar sem falhar e produzir a resposta errada. '
              'Leia os diagnósticos, preveja a saída e acompanhe variáveis passo a passo para investigar.',
          code:
              'var preco = 10;\nvar quantidade = 3;\n// Para calcular o total, use multiplicação.\nvar total = preco * quantidade;\nprint(total);',
          output: '30',
          challenge:
              'Troque * por + e observe o resultado incorreto. Corrija, execute e avance pela aba Depuração. '
              'Depois escreva prec no lugar de preco para observar o diagnóstico e restaure o nome.',
          question:
              'O programa executa, mas calcula 10 + 3 em vez de 10 * 3. Que tipo de erro é esse?',
          answers: [
            'Erro de sintaxe.',
            'Erro de instalação.',
            'Erro de lógica.'
          ],
          correctAnswer: 2,
          feedback:
              'A soma é uma instrução válida, mas não resolve o problema desejado. Isso caracteriza um erro de lógica.',
        ),
        LumiLesson(
          id: 'por-dentro',
          title: 'Por dentro do código',
          minutes: 10,
          explanation:
              'O analisador léxico separa o código em tokens, como números, nomes e operadores. '
              'O parser organiza esses tokens em uma árvore de sintaxe (AST). '
              'Depois das verificações semânticas, o interpretador executa o programa. '
              'As abas Tokens e AST permitem explorar essas representações.',
          code: 'var resultado = 2 + 3 * 4;\nprint(resultado);',
          output: '14',
          challenge:
              'Execute e abra Tokens e AST. Localize os operadores + e *. '
              'Acrescente parênteses em (2 + 3) * 4 e compare a árvore e a saída.',
          question: 'O que a AST representa?',
          answers: [
            'A estrutura sintática do programa.',
            'A lista de arquivos do dispositivo.',
            'Apenas a saída do console.'
          ],
          correctAnswer: 0,
          feedback:
              'A AST organiza a estrutura do código, incluindo expressões, declarações e blocos.',
        ),
        LumiLesson(
          id: 'projeto-final',
          title: 'Missão final: placar Lumi',
          minutes: 20,
          isProject: true,
          explanation:
              'Combine o que aprendeu: variáveis guardam o placar, um laço percorre as rodadas, '
              'uma função calcula os pontos e uma condição anuncia o resultado. '
              'Primeiro preveja o total; depois execute, teste variações e investigue cada etapa.',
          code:
              'fn pontosRodada(rodada) {\n  return rodada * 10;\n}\nvar total = 0;\nfor i in 3 {\n  total = total + pontosRodada(i + 1);\n}\nprint(total);\nif total >= 60 {\n  print("Missão cumprida!");\n} else {\n  print("Continue praticando!");\n}',
          output: '60\nMissão cumprida!',
          challenge:
              'Personalize o placar com 4 rodadas e uma meta de 100 pontos. '
              'Teste também 2 rodadas, explique a diferença e exporte seu projeto pelo editor.',
          question:
              'No exemplo original, quais pontos são somados nas três rodadas?',
          answers: [
            '0, 10 e 20, totalizando 30.',
            '10, 20 e 30, totalizando 60.',
            '30, 30 e 30, totalizando 90.'
          ],
          correctAnswer: 1,
          feedback:
              'i vale 0, 1 e 2. A função recebe i + 1 e devolve 10, 20 e 30. O acumulador termina em 60.',
        ),
      ],
    ),
  ];
}
