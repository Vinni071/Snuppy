# Linguagem Lumi — Referência

Lumi é a linguagem didática do Luminthor. Ela é pequena, tem tipagem dinâmica e foi feita para ensinar lógica de programação: cada passo da execução é registrado para que o estudante veja variáveis, escopos e a pilha de chamadas mudando.

Este documento descreve a linguagem como ela está implementada em [rust_core/](../rust_core/). Quando o comportamento aqui divergir do código, o código é a referência.

## Sumário

1. [Primeiro programa](#1-primeiro-programa)
2. [Estrutura léxica](#2-estrutura-léxica)
3. [Tipos e valores](#3-tipos-e-valores)
4. [Variáveis e constantes](#4-variáveis-e-constantes)
5. [Operadores](#5-operadores)
6. [Saída com `print`](#6-saída-com-print)
7. [Condicionais](#7-condicionais)
8. [Repetições](#8-repetições)
9. [Funções](#9-funções)
10. [Blocos e escopo](#10-blocos-e-escopo)
11. [Erros](#11-erros)
12. [Limites e particularidades](#12-limites-e-particularidades)
13. [Gramática](#13-gramática)
14. [Exemplos completos](#14-exemplos-completos)

---

## 1. Primeiro programa

```lumi
var nome = "Lumi"
print("Olá, " + nome + "!")
```

Saída:

```text
Olá, Lumi!
```

Ponto e vírgula é opcional. Quebras de linha não têm significado para o compilador; as instruções são reconhecidas pela própria estrutura. As formas abaixo são equivalentes:

```lumi
var a = 1
var b = 2
```

```lumi
var a = 1; var b = 2;
```

---

## 2. Estrutura léxica

### Comentários

```lumi
// comentário de linha

/* comentário
   de várias linhas */
```

### Identificadores

Nomes de variáveis, constantes, parâmetros e funções começam com letra ou `_` e continuam com letras, dígitos ou `_`.

- Apenas letras ASCII são aceitas. `var é = 1` gera erro léxico; use `var e = 1`.
- Há distinção entre maiúsculas e minúsculas: `total` e `Total` são nomes diferentes.

### Palavras reservadas

```text
var   const  if     else    while  for    in
fn    return print  break   continue
true  false  null   and     or     not
```

### Literais

| Literal  | Exemplos            | Observação                                          |
|----------|---------------------|-----------------------------------------------------|
| Inteiro  | `0`, `42`, `1000`   | Sem sinal; `-5` é o operador `-` aplicado a `5`.    |
| Decimal  | `3.14`, `0.5`       | Exige dígitos dos dois lados do ponto (`.5` e `5.` são inválidos). |
| Texto    | `"olá"`, `""`       | Somente aspas duplas. Veja [sequências de escape](#texto-sem-sequências-de-escape). |
| Booleano | `true`, `false`     |                                                     |
| Nulo     | `null`              |                                                     |

---

## 3. Tipos e valores

| Tipo     | Nome nas mensagens de erro | Exemplo   |
|----------|----------------------------|-----------|
| Inteiro  | `inteiro`                  | `10`      |
| Decimal  | `decimal`                  | `2.5`     |
| Texto    | `texto`                    | `"abc"`   |
| Booleano | `booleano`                 | `true`    |
| Nulo     | `nulo`                     | `null`    |

A tipagem é dinâmica: o tipo pertence ao valor, não à variável. Uma variável pode receber um inteiro e depois um texto.

### Verdadeiro e falso

Condições (`if`, `while`, `and`, `or`, `not`) aceitam qualquer valor. São considerados **falsos**:

- `false`
- `null`
- `0` e `0.0`
- `""` (texto vazio)

Todo o resto é verdadeiro.

### Como os valores são impressos

| Valor            | `print` mostra |
|------------------|----------------|
| `42`             | `42`           |
| `2.5`            | `2.5`          |
| `3.0`            | `3`            |
| `"oi"`           | `oi` (sem aspas) |
| `true`           | `true`         |
| `null`           | `null`         |

---

## 4. Variáveis e constantes

```lumi
var idade = 17        // variável: pode mudar
const PI = 3.14       // constante: não pode ser reatribuída
var resposta          // sem valor inicial: começa como null
```

### Atribuição

```lumi
var x = 10
x = 20
x += 5    // x = x + 5
x -= 3    // x = x - 3
x *= 2    // x = x * 2
x /= 4    // x = x / 4
```

Regras:

- A variável precisa ter sido declarada antes. Atribuir a um nome desconhecido é erro semântico, com sugestão de nomes parecidos (por exemplo, "Você quis dizer 'pontos'?").
- Atribuir a uma `const` é erro semântico.
- Declarar de novo um nome no mesmo escopo (`var x = 1` seguido de `var x = 2`) é permitido e substitui o valor anterior.
- Não existe `%=`, `++` nem `--`. Use `x = x % 2` e `x += 1`.

---

## 5. Operadores

### Precedência

Da maior para a menor. Operadores na mesma linha são avaliados da esquerda para a direita.

| Nível | Operadores               | Descrição                 |
|-------|--------------------------|---------------------------|
| 1     | `f(...)`, `( ... )`      | Chamada de função, agrupamento |
| 2     | `-x`, `not x`            | Negação numérica, negação lógica |
| 3     | `*`, `/`, `%`            | Multiplicação, divisão, resto |
| 4     | `+`, `-`                 | Soma (ou concatenação), subtração |
| 5     | `<`, `>`, `<=`, `>=`     | Comparação                |
| 6     | `==`, `!=`               | Igualdade                 |
| 7     | `and`                    | E lógico                  |
| 8     | `or`                     | Ou lógico                 |

```lumi
print(2 + 3 * 4)      // 14
print((2 + 3) * 4)    // 20
```

### Aritmética

| Expressão       | Resultado             |
|-----------------|-----------------------|
| `7 + 2`         | `9`                   |
| `7 / 2`         | `3` (divisão inteira) |
| `7.0 / 2`       | `3.5`                 |
| `10 / 4.0`      | `2.5`                 |
| `7 % 3`         | `1`                   |
| `-7 % 3`        | `-1` (sinal do dividendo) |
| `2.0 * 3`       | `6` (decimal impresso sem `.0`) |
| `0.1 + 0.2`     | `0.30000000000000004` |

- Inteiro com inteiro resulta em inteiro. Se um dos lados for decimal, o resultado é decimal.
- Para obter divisão com casas decimais, use um operando decimal: `nota / 2.0`.
- `%` só funciona entre **inteiros**. `1.5 % 2` é erro de execução.
- Dividir por zero (ou calcular o resto por zero) é erro de execução.

### Concatenação de texto

`+` com pelo menos um texto converte o outro lado para texto:

```lumi
print("n = " + 3)              // n = 3
print(3 + " maçãs")            // 3 maçãs
print("ativo: " + true)        // ativo: true
```

Atenção à ordem de avaliação: `1 + 2 + "x"` resulta em `"3x"`, mas `"x" + 1 + 2` resulta em `"x12"`.

### Comparação e igualdade

- `<`, `>`, `<=`, `>=` funcionam entre números (inteiros e decimais podem ser misturados). Comparar textos com `<` é erro.
- `==` e `!=` funcionam entre números, entre textos, entre booleanos e com `null`.
- Comparar tipos diferentes com `==` é **erro de execução**, não `false`: `1 == "1"` falha. A exceção é `null`: `x == null` é sempre válido.
- Comparações não se encadeiam: `1 < x < 3` é erro. Escreva `1 < x and x < 3`.

### Operadores lógicos

`and`, `or` e `not` sempre resultam em `true` ou `false`, aplicando as regras de [verdadeiro e falso](#verdadeiro-e-falso).

```lumi
print(0 or "")          // false
print(not null)         // true
print(5 and "oi")       // true
```

> **Os dois lados são sempre avaliados.** Diferente de muitas linguagens, `and` e `or` não fazem curto-circuito. Em `false and f()`, a função `f` é chamada mesmo assim.

---

## 6. Saída com `print`

```lumi
print("Olá")
print(1 + 2)
print("Total: " + total)
```

- `print` recebe exatamente **uma** expressão, entre parênteses. Para mostrar vários valores, concatene: `print("x = " + x + ", y = " + y)`.
- Cada `print` termina com uma quebra de linha.
- `print` é uma instrução, não uma função: não pode ser usada dentro de expressões (`var r = print(1)` é inválido).
- Não há entrada de dados (leitura do teclado) na linguagem.

---

## 7. Condicionais

```lumi
var nota = 7

if nota >= 9 {
    print("Excelente")
} else if nota >= 6 {
    print("Aprovado")
} else {
    print("Reprovado")
}
```

- A condição não precisa de parênteses, mas eles são permitidos: `if (nota >= 6) { ... }`.
- As chaves são obrigatórias, mesmo para uma única instrução.
- Cada bloco cria um novo escopo (veja [Blocos e escopo](#10-blocos-e-escopo)).

---

## 8. Repetições

### `while`

Repete enquanto a condição for verdadeira.

```lumi
var i = 0
while i < 3 {
    print(i)
    i += 1
}
// 0, 1, 2
```

### `for ... in`

Repete um número fixo de vezes. A expressão depois de `in` deve ser um **inteiro** `N`; a variável assume os valores `0, 1, ..., N-1`.

```lumi
for i in 5 {
    print(i)
}
// 0, 1, 2, 3, 4
```

- Se `N` for `0` ou negativo, o corpo não executa.
- A variável do `for` é somente leitura: `i = 10` dentro do laço é erro semântico.
- A variável só existe dentro do laço.
- Não há listas nem intervalos `a..b`. Para começar de outro valor, calcule a partir de `i` (por exemplo, `var n = i + 1`) ou use `while`.

### `break` e `continue`

```lumi
var soma = 0
for i in 10 {
    if i % 2 == 0 {
        continue        // pula os pares
    }
    if i > 7 {
        break           // encerra o laço
    }
    soma += i
}
print(soma)  // 1 + 3 + 5 + 7 = 16
```

Usar `break` ou `continue` fora de uma repetição é erro semântico.

---

## 9. Funções

```lumi
fn soma(a, b) {
    return a + b
}

print(soma(3, 4))  // 7
```

- Declaradas com `fn nome(param1, param2, ...) { ... }`. Os parâmetros não têm tipo.
- Funções podem ser chamadas **antes** de aparecerem no código, desde que estejam no nível mais externo do programa.
- O número de argumentos precisa ser igual ao número de parâmetros. Caso contrário, é erro semântico.
- Sem `return`, ou com `return` sem valor, a função devolve `null`.
- Os parâmetros se comportam como variáveis comuns e podem ser reatribuídos dentro da função.
- `return` fora de uma função é erro semântico.

### Recursão

```lumi
fn fatorial(n) {
    if n <= 1 {
        return 1
    }
    return n * fatorial(n - 1)
}

print(fatorial(5))  // 120
```

### Restrições

- **Só no nível mais externo.** Uma função declarada dentro de outra função ou bloco não pode ser chamada (erro semântico "A função '...' não foi declarada").
- **Funções não são valores.** Não é possível guardar uma função em variável, passá-la como argumento nem retorná-la.
- **Variáveis globais usadas por uma função precisam ser declaradas antes da função.**

  ```lumi
  var taxa = 2
  fn dobro(x) { return x * taxa }   // ok: taxa já existe
  ```

  ```lumi
  fn dobro(x) { return x * taxa }   // erro: 'taxa' não foi declarada
  var taxa = 2
  ```

- **Escopo dinâmico em execução.** Quando a função é chamada, ela enxerga as variáveis do ponto de chamada. Se o chamador tiver uma variável local com o mesmo nome de uma global usada pela função, a função lê a variável do chamador:

  ```lumi
  var x = 1
  fn f() { return x }

  if true {
      var x = 2
      print(f())   // imprime 2, não 1
  }
  ```

  Para evitar surpresas, passe os valores como parâmetros.

---

## 10. Blocos e escopo

Cada `{ ... }` (corpo de `if`, `else`, `while`, `for`, função ou bloco solto) cria um escopo novo.

```lumi
var x = 1
{
    var x = 2      // nova variável, "esconde" a de fora
    print(x)       // 2
}
print(x)           // 1
```

- Variáveis declaradas dentro de um bloco deixam de existir ao fim dele.
- Atribuir (sem `var`) a uma variável de fora altera a variável de fora:

  ```lumi
  var contador = 0
  if true {
      contador = 5
  }
  print(contador)  // 5
  ```

---

## 11. Erros

O compilador passa o código por quatro etapas. Um erro em uma etapa impede as seguintes.

| Etapa      | Quando ocorre                          | Exemplos                                    |
|------------|----------------------------------------|---------------------------------------------|
| Léxico     | Caractere ou literal inválido          | `var x = @`, `var é = 1`                    |
| Sintaxe    | Estrutura do código incorreta          | falta `{` ou `)`, `var = 10`                |
| Semântico  | Código bem escrito, mas sem sentido    | variável não declarada, atribuir a `const`, `break` fora de laço, número errado de argumentos |
| Execução   | Problema só descoberto ao rodar        | divisão por zero, `1 == "1"`, `true + 1`, `for` sobre texto, limite de passos atingido |

Os erros informam linha e coluna. Erros semânticos de nome desconhecido sugerem nomes parecidos já declarados. Erros de execução mostram a pilha de chamadas.

Exemplo:

```lumi
var pontos = 8
print(pntos)
```

```text
Erro semântico: A variável 'pntos' não foi declarada
Sugestão: Você quis dizer 'pontos'?
```

---

## 12. Limites e particularidades

### Limite de passos

A execução é interrompida depois de **10.000 passos**, para evitar travar o app com repetições infinitas. Cada declaração, atribuição, `print`, chamada de função, iteração de laço e avaliação de condição conta como passo.

```text
Erro de execução: Limite de execução atingido (10000 passos). Verifique se há uma repetição infinita.
```

### Texto sem sequências de escape

O conteúdo entre aspas é usado exatamente como está. `\n`, `\t` e `\"` **não** são convertidos:

```lumi
print("a\nb")    // imprime: a\nb
```

Não é possível incluir aspas duplas dentro de um texto. Para quebrar linhas, use vários `print`.

### `return` sem valor

Como quebras de linha não separam instruções, `return` tenta ler a expressão seguinte. Use `return` sem valor apenas como **última instrução do bloco** (antes de `}`) ou seguido de `;`:

```lumi
fn avisa(x) {
    if x < 0 {
        print("negativo")
        return
    }
    print("ok")
}
```

### O que a linguagem não tem

- Listas, dicionários, objetos ou classes
- Entrada de dados (leitura do teclado)
- Funções nativas além de `print` (por exemplo: tamanho de texto, conversão de tipos, raiz quadrada)
- Funções anônimas ou funções como valores
- Operadores `%=`, `++`, `--`, `**`
- Laço `for` com intervalo personalizado (`a..b`) ou sobre texto

---

## 13. Gramática

EBNF simplificada, extraída de [rust_core/src/parser/mod.rs](../rust_core/src/parser/mod.rs). `;` pode aparecer entre quaisquer instruções e é ignorado.

```text
programa    → instrucao* EOF

instrucao   → declaracao | atribuicao | se | enquanto | para
            | funcao | retorno | imprime | "break" | "continue"
            | bloco | expressao

declaracao  → ("var" | "const") IDENT ("=" expressao)?
atribuicao  → IDENT ("=" | "+=" | "-=" | "*=" | "/=") expressao
se          → "if" expressao bloco ("else" (se | bloco))?
enquanto    → "while" expressao bloco
para        → "for" IDENT "in" expressao bloco
funcao      → "fn" IDENT "(" (IDENT ("," IDENT)*)? ")" bloco
retorno     → "return" expressao?
imprime     → "print" "(" expressao ")"
bloco       → "{" instrucao* "}"

expressao   → ou
ou          → e ("or" e)*
e           → igualdade ("and" igualdade)*
igualdade   → comparacao (("==" | "!=") comparacao)*
comparacao  → soma (("<" | ">" | "<=" | ">=") soma)*
soma        → produto (("+" | "-") produto)*
produto     → unario (("*" | "/" | "%") unario)*
unario      → ("-" | "not") unario | chamada
chamada     → primario ("(" (expressao ("," expressao)*)? ")")*
primario    → INTEIRO | DECIMAL | TEXTO | "true" | "false" | "null"
            | IDENT | "(" expressao ")"

INTEIRO     → [0-9]+
DECIMAL     → [0-9]+ "." [0-9]+
TEXTO       → '"' [^"]* '"'
IDENT       → [a-zA-Z_][a-zA-Z0-9_]*
```

---

## 14. Exemplos completos

### Média e situação

```lumi
const MEDIA_MINIMA = 6.0

fn media(a, b, c) {
    return (a + b + c) / 3.0
}

var m = media(7, 5, 8)
print("Média: " + m)

if m >= MEDIA_MINIMA {
    print("Aprovado")
} else {
    print("Recuperação")
}
```

### Tabuada

```lumi
var n = 7
for i in 10 {
    var fator = i + 1
    print(n + " x " + fator + " = " + n * fator)
}
```

### Fibonacci

```lumi
var a = 0
var b = 1
for i in 10 {
    print(a)
    var proximo = a + b
    a = b
    b = proximo
}
```

### Número primo

```lumi
fn eh_primo(n) {
    if n < 2 {
        return false
    }
    var d = 2
    while d * d <= n {
        if n % d == 0 {
            return false
        }
        d += 1
    }
    return true
}

for i in 20 {
    if eh_primo(i) {
        print(i + " é primo")
    }
}
```

### Máximo divisor comum (recursivo)

```lumi
fn mdc(a, b) {
    if b == 0 {
        return a
    }
    return mdc(b, a % b)
}

print(mdc(48, 18))  // 6
```
