    fn parse_addition(&mut self) -> Result<Expr, CompileError> {
        let mut left = self.parse_multiplication()?;

        while self.check_type("Operator(+)") || self.check_type("Operator(-)") {
            let op_token = self.advance().unwrap();
            let op = match op_token.token_type.as_str() {
                "Operator(+)" => BinaryOperator::Add,
                "Operator(-)" => BinaryOperator::Subtract,
                _ => unreachable!(),
            };
            let right = self.parse_multiplication()?;
            left = Expr {
                span: Span::new(
                    left.span.start,
                    right.span.end,
                    left.span.line,
                    left.span.column,
                ),
                kind: ExprKind::BinaryOp {
                    left: Box::new(left.clone()),
                    op,
                    right: Box::new(right),
                },
            };
        }

        Ok(left)
    }
