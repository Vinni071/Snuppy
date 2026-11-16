    fn record_step(&mut self, span: &Span, action: &str, description: &str) {
        self.step_count += 1;
        self.trace.push(ExecutionStep {
            line: span.line,
            column: span.column,
            action: action.to_string(),
            description: description.to_string(),
            variables: self.env.snapshot_all(),
            scopes: self.env.snapshot_by_scope(),
            scope_depth: self.env.depth(),
            call_stack: self.call_stack.clone(),
            output: None,
        });
    }
